#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

use mimalloc::MiMalloc;
#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

fn main() {
    println!("\n## Start testing Diesel SQLite");
    test_sqlite();
    println!("## End testing Diesel SQLite\n");

    println!("\n## Start testing Diesel PostgreSQL");
    test_postgres();
    println!("## End testing Diesel PostgreSQL\n");

    println!("\n## Start testing Diesel MySQL");
    test_mysql();
    println!("## End testing Diesel MySQL\n");

    println!("\n## Start testing CURL");
    test_curl();
    println!("## End testing CURL\n");

    println!("\n## Start testing JSON Serde");
    test_json();
    println!("## End testing JSON Serde\n");

    println!("\n## Start testing OpenSSL");
    test_openssl();
    println!("## End testing OpenSSL\n");

    println!("\n## Start testing ZLib");
    test_zlib();
    println!("## End testing ZLib\n");

    println!("\n## Start testing MiMalloc");
    test_mimalloc();
    println!("## End testing MiMalloc\n");
}

// == Diesel Testing

#[macro_use]
extern crate diesel;
// Also include diesel_migrations because it can causes some issues during compiling with C Libs.
#[macro_use]
#[allow(unused_imports)]
extern crate diesel_migrations;

mod schema {
    table! {
        posts (id) {
            id -> Int4,
            title -> Varchar,
            body -> Text,
            published -> Bool,
        }
    }
}

mod models {
    use crate::schema::posts;
    #[derive(Queryable)]
    pub struct Post {
        pub id: i32,
        pub title: String,
        pub body: String,
        pub published: bool,
    }

    // apparently this can be done without heap storage, but lifetimes spread far..
    #[derive(Insertable)]
    #[diesel(table_name = posts)]
    pub struct NewPost {
        pub title: String,
        pub body: String,
    }
}
use diesel::prelude::*;

fn test_sqlite() {
    // Unsafe function to extract the library version
    let lib_version = unsafe { libsqlite3_sys::sqlite3_libversion_number() };
    println!("sqlite3 lib version: {lib_version:?}",);

    let database_url = std::env::var("DATABASE_URL_SQLITE").unwrap_or_else(|_| "main.db".into());
    SqliteConnection::establish(&database_url).unwrap();
}

fn test_postgres() {
    // Unsafe function to extract the library version
    let lib_version = unsafe { pq_sys::PQlibVersion() };
    println!("postgres lib version: {lib_version:?}",);

    let database_url = std::env::var("DATABASE_URL_PG")
        .unwrap_or_else(|_| "postgres://localhost?connect_timeout=1&sslmode=require".into());
    match PgConnection::establish(&database_url) {
        Err(e) => {
            println!("Should fail to connect here:");
            println!("{e}");
        }
        Ok(_) => {
            unreachable!();
        }
    }
}

fn test_mysql() {
    // Unsafe function to extract the library version
    let lib_version = unsafe { mysqlclient_sys::mysql_get_client_version() };
    println!("mysql/mariadb lib version: {lib_version:?}",);

    let database_url = std::env::var("DATABASE_URL_MYSQL")
        .unwrap_or_else(|_| "mysql://localhost?connect_timeout=1&sslmode=require".into());
    match MysqlConnection::establish(&database_url) {
        Err(e) => {
            println!("Should fail to connect here:");
            println!("{e}");
        }
        Ok(_) => {
            unreachable!();
        }
    }
}

// == Curl Testing

use curl::easy::Easy;
use std::io::{stdout, Write};
use std::process;
fn test_curl() {
    let url = "https://raw.githubusercontent.com/BlackDex/rust-musl/main/.gitignore";

    let mut easy = Easy::new();
    easy.fail_on_error(true).unwrap();
    easy.url(url).unwrap();
    easy.write_function(|data| Ok(stdout().write(data).unwrap()))
        .unwrap();
    easy.perform().unwrap_or_else(|e| {
        println!("Failed: {e}");
        process::exit(1);
    });
}

// == Serde Testing

#[macro_use]
extern crate serde;
#[macro_use]
extern crate serde_json;

#[derive(Serialize, Deserialize, Debug)]
struct Point {
    x: i32,
    y: i32,
}

// == JSON Testing

fn test_json() {
    let point = Point { x: 1, y: 2 };

    // Convert the Point to a JSON string.
    let serialized = serde_json::to_string(&point).unwrap();

    // Prints serialized = {"x":1,"y":2}
    println!("serialized = {serialized}");

    // Convert the JSON string back to a Point.
    let deserialized: Point = serde_json::from_str(&serialized).unwrap();

    // Prints deserialized = Point { x: 1, y: 2 }
    println!("deserialized = {deserialized:?}");

    // Generate json via macro
    let json_macro = json!({
        "Object": {
            "ArrayOne": [
                "one",
                "two"
            ],
            "ArrayTwo": [
                "three",
                "four"
            ],
        },
        "Boolean": true,
        "Int": 10,
        "Float": 42.42,
        "String": "Hello World"
    });
    println!("json_macro = {json_macro:#?}");
}

// == OpenSSL Testing

fn test_openssl() {
    use openssl::{
        hash::{hash, MessageDigest},
        version::{platform, version},
    };
    use std::str;

    let data: &[u8] = b"Hello, OpenSSL world";
    let digest = hash(MessageDigest::sha256(), data);

    println!("version: {}", version());
    println!("{}", platform());
    println!("{}", str::from_utf8(data).ok().unwrap());
    println!("hash:  {digest:x?}");
    println!("sha256sum: d7, 4d, a9, c1, a1, 35, 6a, 18, fd, d1, d7, 48, e8, d8, 8c, 4d, 3d, e2, b6, 3b, 20, 34, 82, ee, 3, 29, d7, 1, 4b, fc, 51, 77");
}

// == ZLib Testing

use flate2::read::ZlibDecoder;
use flate2::write::ZlibEncoder;
use flate2::Compression;
use std::io;
use std::io::prelude::*;

// Compress a sample string and print it after transformation.
fn test_zlib() {
    let mut e = ZlibEncoder::new(Vec::new(), Compression::default());
    let input = "Hello Compressed World!";
    e.write_all(input.as_bytes()).unwrap();
    let bytes = e.finish().unwrap();

    println!("input: {input:?}");
    println!("input bytes: {:?}", input.as_bytes());
    println!("compressed: {bytes:?}");
    println!("decompressed: {:?}", test_zlib_decode(bytes).unwrap());
}

// Uncompresses a Zlib Encoded vector of bytes and returns a string or error
// Here &[u8] implements Read
fn test_zlib_decode(bytes: Vec<u8>) -> io::Result<String> {
    let mut z = ZlibDecoder::new(&bytes[..]);
    let mut s = String::new();
    z.read_to_string(&mut s)?;
    Ok(s)
}

// == MiMalloc Testing

fn test_mimalloc() {
    let lib_version = unsafe { libmimalloc_sys::mi_version() };
    println!("mimalloc version: {lib_version:?}");
}
