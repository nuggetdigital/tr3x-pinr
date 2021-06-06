#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use anyhow::{bail, Result};
use http::StatusCode;
use log::debug;
use reqwest::blocking;
use serde::{Deserialize, Serialize};
use serde_json::json;
use url::Url;

#[get("/")]
fn index() -> &'static str {
    "fraud world"
}

fn main() {
    rocket::ignite().mount("/", routes![index]).launch();
}