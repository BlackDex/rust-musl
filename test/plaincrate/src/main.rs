extern crate rand;

fn main() {
    let nr = rand::random::<(u32)>();
    println!("Hello, visitor number {}", nr);
}
