#![deny(warnings)]
extern crate pretty_env_logger;
#[macro_use]
extern crate log;
mod util;
use hyper::{
    service::{make_service_fn, service_fn},
    Client, Error, Method, Server,
};
use util::{crop, looks_like_cid};

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let from_port = env!("PRXY_FROM_PORT")
        .to_string()
        .parse::<u16>()
        .unwrap_or(5000);
    let to_port = env!("PRXY_TO_PORT")
        .to_string()
        .parse::<u16>()
        .unwrap_or(5001);

    let client = Client::builder()
        .http1_title_case_headers(true)
        .http1_preserve_header_case(true)
        .build_http();

    // the `make_service_fn` closure is run for each connection...
    let make_service = make_service_fn(move |_| {
        let client = client.clone();

        async move {
            // `service_fn` is a helper to convert a function that
            // returns a Response into a `Service`.
            Ok::<_, Error>(service_fn(move |mut req| {
                let req_path = req.uri().path();
                let req_meth = req.method();
                let path_part = crop(req_path, 1);

                match (req_meth, req_path) {
                    (&Method::GET, _req_path) if looks_like_cid(path_part) => {
                        debug!("CAT ARM");
                        let uri_string = format!(
                            "http://127.0.0.1:{}/api/v0/cat?arg={}",
                            to_port, path_part
                        );
                        let uri = uri_string.parse().expect("uri");
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                    }
                    (&Method::GET, "/status") => {
                        debug!("STATUS ARM");
                        let uri_string = format!(
                            "http://127.0.0.1:{}/api/v0/version",
                            to_port
                        );
                        let uri = uri_string.parse().expect("uri");
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                    }
                    (&Method::POST, "/") => {
                        debug!("ADD ARM");
                        let uri_string = format!(
                            "http://127.0.0.1:{}/api/v0/add?cid-version=1&hash=blake2b-256&pin=false",
                            to_port
                        );
                        let uri = uri_string.parse().expect("uri");
                        *req.uri_mut() = uri;
                    }
                    _ => {
                        warn!("FELL THRU");
                        // NOTE: duno how2 cnstrct a res fut so redirectin 2a deadend
                        let uri_string = format!(
                            "http://127.0.0.1:{}/api/v0/deadend",
                            to_port
                        );
                        let uri = uri_string.parse().expect("uri");
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                    }
                };

                client.request(req)

                // TODO: strip unnecessary response headers
                // server, trailer, vary, date
            }))
        }
    });

    let server =
        Server::bind(&([127, 0, 0, 1], from_port).into()).serve(make_service);

    info!("listening on http://localhost:{}", from_port);
    info!("proxying to http://localhost:{}", to_port);

    if let Err(e) = server.await {
        error!("server error: {}", e);
    }
}
