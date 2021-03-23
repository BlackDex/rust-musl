extern crate curl;

use std::process;
use std::io::{stdout, Write};
use curl::easy::Easy;

fn main() {
    let url = "https://raw.githubusercontent.com/clux/muslrust/master/test/curlcrate/src/main.rs";

    let mut easy = Easy::new();
    easy.fail_on_error(true).unwrap();
    easy.url(url).unwrap();
    easy.write_function(|data| {
        Ok(stdout().write(data).unwrap())
    }).unwrap();
    easy.perform().unwrap_or_else(|e| {
      println!("Failed: {}", e);
      process::exit(1);
    });
    // NB: This is a quine
}
