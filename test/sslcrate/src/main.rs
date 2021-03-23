extern crate openssl;
use std::str;
use openssl::hash::{hash, MessageDigest};


fn main() {
    let data: &[u8] = b"Hello, world";
    let digest = hash(MessageDigest::sha256(), &data);

    println!("{}", str::from_utf8(data).ok().unwrap());
    println!("hash: {:?}", digest);
}
