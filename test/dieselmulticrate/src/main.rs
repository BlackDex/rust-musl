#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

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
use diesel::sqlite::SqliteConnection;

fn main() {
    let database_url = std::env::var("DATABASE_URL").unwrap_or_else(|_| "main.db".into());
    SqliteConnection::establish(&database_url).unwrap();
}
