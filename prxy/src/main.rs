#![deny(warnings)]

extern crate pretty_env_logger;
#[macro_use]
extern crate log;

use hyper::{
    service::{make_service_fn, service_fn},
    Client, Server,
};
use std::convert::Infallible;

mod lib;

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let (from_port, to_port) = lib::parse_ports();

    let client = Client::builder().build_http();

    let server = Server::bind(&([0, 0, 0, 0], from_port).into()).serve(
        make_service_fn(move |_| {
            let client = client.clone();
            async move {
                Ok::<_, Infallible>(service_fn(move |req| {
                    lib::proxy(client.clone(), req, to_port)
                }))
            }
        }),
    );

    info!(
        "prxy http://0.0.0.0:{} -> http://localhost:{}",
        from_port, to_port
    );

    if let Err(e) = server.await {
        error!("server error: {}", e);
    }
}
