#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]
#![warn(rust_2024_compatibility)]

// The `openssl` crate must be included before the `diesel` crate.
// Else, this generates linking errors with the static build libpq because it needs libssl, but pq-sys never includes it.
#[allow(unused_extern_crates)]
extern crate openssl;

#[macro_use]
extern crate diesel;

// Also include diesel_migrations because it causes some other issues during compiling.
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
    #[allow(dead_code)]
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

use diesel::pg::PgConnection;
use diesel::prelude::*;

fn main() {
    // Unsafe function to extract the library version
    let lib_version = unsafe { pq_sys::PQlibVersion() };
    println!("postgres lib version: {lib_version:?}",);

    let database_url = std::env::var("DATABASE_URL")
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
