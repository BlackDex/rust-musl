#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

use curl::easy::Easy;
use std::io::{stdout, Write};
use std::process;

fn main() {
    let version = curl::Version::get();
    println!("version/features: \n{version:#?}");

    let url = "https://raw.githubusercontent.com/clux/muslrust/master/test/curlcrate/src/main.rs";

    let mut easy = Easy::new();
    easy.fail_on_error(true).unwrap();
    easy.url(url).unwrap();
    easy.write_function(|data| Ok(stdout().write(data).unwrap()))
        .unwrap();
    easy.perform().unwrap_or_else(|e| {
        println!("Failed: {}", e);
        process::exit(1);
    });
}
