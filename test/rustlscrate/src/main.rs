#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

use hyper::{Body, Client, Uri};

#[tokio::main]
async fn main() {
    let url: Uri =
        "https://raw.githubusercontent.com/BlackDex/rust-musl/main/test/hypercrate/Cargo.toml"
            .parse()
            .unwrap();

    let https = hyper_rustls::HttpsConnectorBuilder::new()
        .with_native_roots()
        .https_only()
        .enable_http1()
        .build();

    let client: Client<_, Body> = Client::builder().build(https);

    let resp = client.get(url).await.unwrap();
    assert_eq!(resp.status(), 200);

    let body = resp.into_body();
    let body = hyper::body::to_bytes(body).await.unwrap();
    let body = String::from_utf8(body.to_vec()).unwrap();
    let lines: Vec<&str> = body.split_terminator('\n').collect();
    for line in lines.iter() {
        println!("{}", line);
    }

    // while let Some(next) = res.data().await {
    //     let chunk = next.unwrap();
    //     io::stdout().write_all(&chunk).await.unwrap();
    // }
}
