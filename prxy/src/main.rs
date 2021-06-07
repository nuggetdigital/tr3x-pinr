#![deny(warnings)]

mod util;

use hyper::{
    service::{make_service_fn, service_fn},
    Client, Error, Method, Server,
};
use std::net::SocketAddr;
use util::{crop, looks_like_cid};

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let in_addr = ([127, 0, 0, 1], 5000).into();
    let out_addr: SocketAddr = ([127, 0, 0, 1], 5001).into();

    let client_main = Client::new();

    let out_addr_clone = out_addr.clone();

    // The closure inside `make_service_fn` is run for each connection,
    // creating a 'service' to handle requests for that specific connection.
    let make_service = make_service_fn(move |_| {
        let client = client_main.clone();

        async move {
            // This is the `Service` that will handle the connection.
            // `service_fn` is a helper to convert a function that
            // returns a Response into a `Service`.
            Ok::<_, Error>(service_fn(move |mut req| {
                let req_path = req.uri().path();
                let path_part = crop(req_path, 1);

                match (req.method(), req_path) {
                    (&Method::GET, _req_path) if looks_like_cid(path_part) => {
                        let uri_string =
                            format!("http://{}/api/v0/cat?arg={}", out_addr_clone, path_part,);
                        // TODO rm unwrap
                        let uri = uri_string.parse().unwrap();
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                        client.request(req)
                    }
                    (&Method::GET, "/status") => {
                        // TODO check ipfs-pinr is alive then 200/500
                        let uri_string = format!("http://{}/api/v0/version", out_addr_clone);
                        // TODO rm unwrap
                        let uri = uri_string.parse().unwrap();
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                        client.request(req)
                    }
                    (&Method::POST, "/") => {
                        let uri_string = format!(
                            "http://{}/api/v0/add?cid-version=1&hash=blake2b-256&pin=false",
                            out_addr_clone,
                        );
                        // TODO rm unwrap
                        let uri = uri_string.parse().unwrap();
                        *req.uri_mut() = uri;
                        client.request(req)
                    }
                    _ => {
                        // NOTE: duno how2 cnstrct a res fut so redirectin 2a deadend
                        let uri_string = format!("http://{}/api/v0/notfound", out_addr_clone);
                        // TODO rm unwrap
                        let uri = uri_string.parse().unwrap();
                        *req.uri_mut() = uri;
                        *req.method_mut() = Method::POST;
                        client.request(req)
                    }
                }
            }))
        }
    });

    let server = Server::bind(&in_addr).serve(make_service);

    println!("Listening on http://{}", in_addr);
    println!("Proxying on http://{}", out_addr);

    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }
}
