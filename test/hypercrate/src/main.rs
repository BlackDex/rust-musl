#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

use hyper_openssl::HttpsConnector;

#[tokio::main]
async fn main() {
    let url: hyper::Uri =
        "https://raw.githubusercontent.com/BlackDex/rust-musl/main/test/hypercrate/Cargo.toml"
            .parse()
            .unwrap();

    let tls_connector = HttpsConnector::new().unwrap();
    let client: hyper::Client<_, hyper::Body> = hyper::Client::builder().build(tls_connector);

    let resp = client.get(url).await.unwrap();

    println!("Response: {}\n", resp.status());
    assert!(resp.status().is_success());

    let body = resp.into_body();
    let body = hyper::body::to_bytes(body).await.unwrap();
    let body = String::from_utf8(body.to_vec()).unwrap();
    let lines: Vec<&str> = body.split_terminator('\n').collect();
    for line in lines.iter() {
        println!("{}", line);
    }
}
