use hyper::{
    body as hyper_body,
    client::HttpConnector,
    header::{self, HeaderValue},
    Body as HyperBody, Client, Error, Method, Request, Response, StatusCode,
    Uri,
};
use hyper_multipart_rfc7578::client::multipart::{Body as MultiBody, Form};
use infer::get as infer;
use lazy_static::lazy_static;
use log::debug;
use regex::Regex;
use std::io::Cursor;

#[inline]
fn rm_first_char(s: &str) -> &str {
    if s.len() <= 1 {
        ""
    } else {
        &s[1..]
    }
}

#[inline]
fn looks_like_cid(part: &str) -> bool {
    lazy_static! {
        static ref NAIVE_CID_PATTERN: Regex =
            Regex::new("^[a-z2-7]{32,128}$").expect("naive cid pattern");
    }
    NAIVE_CID_PATTERN.is_match(part)
}

#[inline]
fn parse_uri(s: String) -> Uri {
    s.parse().expect("uri") // TODO: get rid of expect
}

#[inline]
fn strip_bloat_headers(mut res: Response<HyperBody>) -> Response<HyperBody> {
    let hdrs = res.headers_mut();
    hdrs.remove("server");
    hdrs.remove("trailer");
    hdrs.remove("vary");
    hdrs.remove("access-control-allow-headers");
    hdrs.remove("access-control-expose-headers");
    hdrs.remove("x-content-length");
    hdrs.remove("x-stream-output");
    hdrs.remove("x-chunked-output");
    res
}

#[inline]
fn strip_status_headers(mut res: Response<HyperBody>) -> Response<HyperBody> {
    let hdrs = res.headers_mut();
    hdrs.remove("transfer-encoding");
    hdrs.remove("content-type");
    res
}

#[inline]
pub fn parse_ports() -> (u16, u16) {
    (
        env!("PRXY_FROM_PORT")
            .to_string()
            .parse::<u16>()
            .unwrap_or(5000),
        env!("PRXY_TO_PORT")
            .to_string()
            .parse::<u16>()
            .unwrap_or(5001),
    )
}

async fn to_formdata_request(
    req: Request<HyperBody>,
    to_port: u16,
) -> Result<Request<HyperBody>, Error> {
    let mut form = Form::default();

    form.add_reader(
        "file",
        Cursor::new(hyper_body::to_bytes(req.into_body()).await?),
    );

    let uri = parse_uri(format!(
        "http://127.0.0.1:{}/api/v0/add?cid-version=1&hash=blake2b-256&pin=false",
        to_port
    ));

    let formdata_req = form
        .set_body_convert::<HyperBody, MultiBody>(Request::post(uri))
        .expect("formdata req"); // TODO: get rid of expect

    Ok(formdata_req)
}

fn mime_type(buf: &[u8]) -> &'static str {
    if let Some(kind) = infer(buf) {
        kind.mime_type()
    } else {
        "application/octet-stream"
    }
}

pub async fn proxy(
    client: Client<HttpConnector>,
    mut req: Request<HyperBody>,
    to_port: u16,
) -> Result<Response<HyperBody>, Error> {
    debug!("incomin {:?}", &req);

    let req_meth = req.method();
    let req_path = req.uri().path();
    let path_part = rm_first_char(req_path);

    match (req_meth, req_path) {
        (&Method::GET, _req_path) if looks_like_cid(path_part) => {
            let uri = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/cat?arg={}",
                to_port, path_part
            ));

            let alt_req = Request::post(uri)
                .body(HyperBody::empty())
                .expect("alt req"); // TODO: get rid of expect

            let mut res = client.request(alt_req).await?;

            let buf = hyper_body::to_bytes(res.body_mut()).await?;
            let mime = mime_type(&buf);

            let mut alt_res = Response::new(HyperBody::from(buf));
            alt_res
                .headers_mut()
                .insert(header::CONTENT_TYPE, HeaderValue::from_static(mime));
            *alt_res.status_mut() = StatusCode::OK;

            Ok(alt_res)
        }
        (&Method::GET, "/status") => {
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/version",
                to_port
            ));
            *req.method_mut() = Method::POST;

            let mut res = client.request(req).await?;
            *res.body_mut() = HyperBody::empty();

            let res = strip_status_headers(strip_bloat_headers(res));

            Ok(res)
        }
        (&Method::POST, "/") => {
            let formdata_req = to_formdata_request(req, to_port).await?;
            let res = client.request(formdata_req).await?;
            let res = strip_bloat_headers(res);
            Ok(res)
        }
        _ => {
            let mut res = Response::new(HyperBody::empty());
            *res.status_mut() = StatusCode::BAD_REQUEST;
            Ok(res)
        }
    }
}
