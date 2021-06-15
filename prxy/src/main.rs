#![deny(warnings)]

extern crate pretty_env_logger;
#[macro_use]
extern crate log;

use hyper::{
    client::HttpConnector,
    service::{make_service_fn, service_fn},
    Body, Client, Server,
};
use hyper_timeout::TimeoutConnector;
use std::{convert::Infallible, time::Duration};

mod lib;

#[tokio::main]
async fn main() {
    pretty_env_logger::init();

    let (from_port, to_port) = lib::parse_ports();

    let mut connector = TimeoutConnector::new(HttpConnector::new());
    connector.set_connect_timeout(Some(Duration::from_secs(5)));
    connector.set_read_timeout(Some(Duration::from_secs(5)));
    connector.set_write_timeout(Some(Duration::from_secs(5)));
    let client = Client::builder().build::<_, Body>(connector);

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
