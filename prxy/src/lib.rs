use hyper::{Body, Client, Method, Request, Response, StatusCode, Uri};
use lazy_static::lazy_static;
use log::{debug, warn};
use regex::Regex;

type HttpClient = Client<hyper::client::HttpConnector>;

#[inline]
pub fn rm_first_char(s: &str) -> &str {
    if s.len() <= 1 {
        ""
    } else {
        &s[1..]
    }
}

#[inline]
pub fn looks_like_cid(part: &str) -> bool {
    lazy_static! {
        static ref NAIVE_CID_PATTERN: Regex =
            Regex::new("^[a-z2-7]{32,128}$").unwrap();
    }
    NAIVE_CID_PATTERN.is_match(part)
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

#[inline]
pub fn parse_uri(s: String) -> Uri {
    s.parse().expect("uri")
}

// TODO: strip unnecessary response headers
// server, trailer, vary, date
pub async fn proxy(
    client: HttpClient,
    mut req: Request<Body>,
    to_port: u16,
) -> Result<Response<Body>, hyper::Error> {
    let req_path = req.uri().path();
    let req_meth = req.method();
    let path_part = rm_first_char(req_path);

    match (req_meth, req_path) {
        (&Method::GET, _req_path) if looks_like_cid(path_part) => {
            debug!("CAT ARM");
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/cat?arg={}",
                to_port, path_part
            ));
            *req.method_mut() = Method::POST;
            client.request(req).await
        }
        (&Method::GET, "/status") => {
            debug!("STATUS ARM");
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/version",
                to_port
            ));
            *req.method_mut() = Method::POST;
            client.request(req).await
        }
        (&Method::POST, "/") => {
            debug!("ADD ARM");
            *req.uri_mut() = parse_uri(format!(
                "http://127.0.0.1:{}/api/v0/add?cid-version=1&hash=blake2b-256&pin=false",
                to_port
            ));
            client.request(req).await
        }
        _ => {
            warn!("FELL THRU");
            let mut resp = Response::new(Body::empty());
            *resp.status_mut() = StatusCode::NOT_FOUND;
            Ok(resp)
        }
    }
}
