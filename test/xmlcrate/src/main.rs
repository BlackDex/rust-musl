#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]
#![warn(rust_2024_compatibility)]

use libxml::parser::Parser;
use libxml::xpath::Context;

fn main() {
  let parser = Parser::default();
  let doc = parser.parse_file("test.xml").unwrap();
  let context = Context::new(&doc).unwrap();
  let result = context.evaluate("//child/text()").unwrap();

  for node in &result.get_nodes_as_vec() {
    println!("Found: {}", node.get_content());
  }
}
