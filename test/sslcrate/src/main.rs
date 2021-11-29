extern crate openssl;
use std::str;
use openssl::{hash::{hash, MessageDigest}, version::{version, platform}};


fn main() {
    let data: &[u8] = b"Hello, OpenSSL world";
    let digest = hash(MessageDigest::sha256(), &data);

    println!("version: {}", version());
    println!("{}", platform());
    println!("{}", str::from_utf8(data).ok().unwrap());
    println!("hash:  {:x?}", digest);
    println!("sha256sum: d7, 4d, a9, c1, a1, 35, 6a, 18, fd, d1, d7, 48, e8, d8, 8c, 4d, 3d, e2, b6, 3b, 20, 34, 82, ee, 3, 29, d7, 1, 4b, fc, 51, 77");
}
