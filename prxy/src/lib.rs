use hyper::{
    body as hyper_body,
    client::HttpConnector,
    header::{HeaderValue, CONTENT_TYPE},
    Body as HyperBody, Client, Error, Method, Request, Response, StatusCode,
    Uri,
};
use hyper_multipart_rfc7578::client::multipart::{Body as MultiBody, Form};
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
    s.parse().expect("uri")
}

#[inline]
fn strip_headers(mut res: Response<HyperBody>) -> Response<HyperBody> {
    let hdrs = res.headers_mut();
    hdrs.remove("Server");
    hdrs.remove("Trailer");
    hdrs.remove("Vary");
    hdrs.remove("Access-Control-Allow-Headers");
    hdrs.remove("Access-Control-Expose-Headers");
    hdrs.remove("X-Content-Length");
    hdrs.remove("X-Stream-Output");
    hdrs.remove("X-Chunked-Output");
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

    // TODO: get rid of expect
    let formdata_req = form
        .set_body_convert::<HyperBody, MultiBody>(Request::post(uri))
        .expect("formdata req");

    Ok(formdata_req)
}

pub async fn proxy(
    client: Client<HttpConnector>,
    mut req: Request<HyperBody>,
    to_port: u16,
) -> Result<Response<HyperBody>, Error> {
    let req_path = req.uri().path();
    let req_meth = req.method();
    let path_part = rm_first_char(req_path);

    debug!("incomin {:?}", &req);

    match (req_meth, req_path) {
        (&Method::GET, _req_path) if looks_like_cid(path_part) => {
            let uri = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/cat?arg={}",
                to_port, path_part
            ));
            // TODO: get rid of expect
            let alt_req = Request::post(uri)
                .body(HyperBody::empty())
                .expect("alt req");
            let mut res = client.request(alt_req).await?;
            res.headers_mut().insert(
                CONTENT_TYPE,
                HeaderValue::from_static("application/octet-stream"),
            );
            Ok(strip_headers(res))
        }
        (&Method::GET, "/status") => {
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/version",
                to_port
            ));
            *req.method_mut() = Method::POST;
            let mut res = client.request(req).await?;
            *res.body_mut() = HyperBody::empty();
            Ok(strip_headers(res))
        }
        (&Method::POST, "/") => {
            let formdata_req = to_formdata_request(req, to_port).await?;
            let res = client.request(formdata_req).await?;
            Ok(strip_headers(res))
        }
        _ => {
            let mut resp = Response::new(HyperBody::empty());
            *resp.status_mut() = StatusCode::NOT_FOUND;
            Ok(resp)
        }
    }
}
