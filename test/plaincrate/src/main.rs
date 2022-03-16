#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

fn main() {
    let nr = rand::random::<u32>();
    println!("Hello, visitor number {}", nr);
}
