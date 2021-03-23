extern crate futures;
extern crate hyper;
extern crate tokio_core;
extern crate hyper_openssl;

use std::env;
use std::io::{self, Write};

use futures::Future;
use futures::stream::Stream;

use hyper::Client;
use hyper_openssl::HttpsConnector;

fn main() {
    // set SSL_CERT location - see issue #5
    // normally you'd want to set this in your docker container
    // but for plain bin distribution and this test, we set it here
    env::set_var("SSL_CERT_FILE", "/etc/ssl/certs/ca-certificates.crt");

    let url = "https://raw.githubusercontent.com/clux/muslrust/master/README.md";
    let url = url.parse::<hyper::Uri>().unwrap();

    let mut core = tokio_core::reactor::Core::new().unwrap();

    let client = Client::configure()
        .connector(HttpsConnector::new(4, &core.handle()).unwrap())
        .build(&core.handle());

    let work = client.get(url).and_then(|res| {
        println!("Response: {}", res.status());
        assert!(res.status().is_success());

        res.body().for_each(|chunk| {
            io::stdout().write_all(&chunk).map_err(From::from)
        })
    });

    core.run(work).unwrap();
}
