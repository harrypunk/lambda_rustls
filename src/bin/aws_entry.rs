use lambda_runtime::{handler_fn, Context, Error};
use log::LevelFilter;
use serde::{Deserialize, Serialize};
use simple_error::SimpleError;
use simple_logger::SimpleLogger;
use std::collections::HashMap;

#[derive(Deserialize)]
struct Request {}

#[derive(Serialize)]
struct Response {
    req_id: String,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    SimpleLogger::new()
        .with_level(LevelFilter::Info)
        .init()
        .unwrap();

    lambda_runtime::run(handler_fn(hello)).await?;
    Ok(())
}

pub(crate) async fn hello(_event: Request, ctx: Context) -> Result<Response, SimpleError> {
    let resp = reqwest::blocking::get("https://httpbin.org/ip")
        .expect("request error")
        .json::<HashMap<String, String>>()
        .expect("json error");
    println!("{:#?}", resp);

    log::info!("hello lambda");
    Ok(Response {
        req_id: ctx.request_id,
    })
}
