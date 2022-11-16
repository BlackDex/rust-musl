#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

use hyper::{body::HttpBody as _, Body, Client, Uri};
use hyper_tls::HttpsConnector;
use tokio::io::{self, AsyncWriteExt as _};

#[tokio::main]
async fn main() {
    let url: Uri =
        "https://raw.githubusercontent.com/BlackDex/rust-musl/main/test/hypercrate/Cargo.toml"
            .parse()
            .unwrap();

    let https = HttpsConnector::new();
    let client = Client::builder().build::<_, Body>(https);

    let mut res = client.get(url).await.unwrap();
    assert_eq!(res.status(), 200);

    while let Some(next) = res.data().await {
        let chunk = next.unwrap();
        io::stdout().write_all(&chunk).await.unwrap();
    }
}
