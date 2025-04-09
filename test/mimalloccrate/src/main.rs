#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]
#![warn(rust_2024_compatibility)]

use mimalloc::MiMalloc;
#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

fn main() {
    let world = String::from("world");
    let version = MiMalloc.version();
    println!("Hello, {world}!");
    println!("MiMalloc version: {version}");
}
