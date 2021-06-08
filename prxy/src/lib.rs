use hyper::{
    client::HttpConnector, Body, Client, Method, Request, Response, StatusCode,
    Uri,
};
use lazy_static::lazy_static;
use regex::Regex;

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
fn strip_headers(mut res: Response<Body>) -> Response<Body> {
    let hdrs = res.headers_mut();
    hdrs.remove("Server");
    hdrs.remove("Trailer");
    hdrs.remove("Vary");
    hdrs.remove("Access-Control-Allow-Headers");
    hdrs.remove("Access-Control-Expose-Headers");
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

pub async fn proxy(
    client: Client<HttpConnector>,
    mut req: Request<Body>,
    to_port: u16,
) -> Result<Response<Body>, hyper::Error> {
    let req_path = req.uri().path();
    let req_meth = req.method();
    let path_part = rm_first_char(req_path);

    match (req_meth, req_path) {
        (&Method::GET, _req_path) if looks_like_cid(path_part) => {
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/cat?arg={}",
                to_port, path_part
            ));
            *req.method_mut() = Method::POST;
            let res = client.request(req).await?;
            Ok(strip_headers(res))
        }
        (&Method::GET, "/status") => {
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/version",
                to_port
            ));
            *req.method_mut() = Method::POST;
            let res = client.request(req).await?;
            Ok(strip_headers(res))
        }
        (&Method::POST, "/") => {
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/add?cid-version=1&hash=blake2b-256&pin=false",
                to_port
            ));
            let res = client.request(req).await?;
            Ok(strip_headers(res))
        }
        _ => {
            let mut resp = Response::new(Body::empty());
            *resp.status_mut() = StatusCode::NOT_FOUND;
            Ok(resp)
        }
    }
}
