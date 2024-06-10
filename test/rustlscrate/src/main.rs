#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

// use http::Uri;
use http_body_util::{BodyExt, Empty};
use hyper::body::Bytes;
use hyper_rustls::ConfigBuilderExt;
use hyper_util::{client::legacy::Client, rt::TokioExecutor};

use std::io;

fn main() {
    // Set a process wide default crypto provider.
    let _ = rustls::crypto::ring::default_provider().install_default();

    // Send GET request and inspect result, with proper error handling.
    if let Err(e) = run_client() {
        eprintln!("FAILED: {}", e);
        std::process::exit(1);
    }
}

fn error(err: String) -> io::Error {
    io::Error::new(io::ErrorKind::Other, err)
}

#[tokio::main]
async fn run_client() -> io::Result<()> {
    // Prepare the TLS client config
    let tls = rustls::ClientConfig::builder()
        .with_webpki_roots()
        .with_no_client_auth();

    // Prepare the HTTPS connector
    let https = hyper_rustls::HttpsConnectorBuilder::new()
        .with_tls_config(tls)
        .https_or_http()
        .enable_http1()
        .build();

    // Build the hyper client from the HTTPS connector.
    let client: Client<_, Empty<Bytes>> = Client::builder(TokioExecutor::new()).build(https);

    // Prepare a chain of futures which sends a GET request, inspects
    // the returned headers, collects the whole body and prints it to
    // stdout.
    let fut = async move {
        let res = client
            .get("https://raw.githubusercontent.com/BlackDex/rust-musl/main/test/hypercrate/Cargo.toml".parse().unwrap())
            .await
            .map_err(|e| error(format!("Could not get: {:?}", e)))?;
        println!("Status:\n{}", res.status());
        println!("Headers:\n{:#?}", res.headers());

        let body = res
            .into_body()
            .collect()
            .await
            .map_err(|e| error(format!("Could not get body: {:?}", e)))?
            .to_bytes();
        println!("Body:\n{}", String::from_utf8_lossy(&body));

        Ok(())
    };

    fut.await
}