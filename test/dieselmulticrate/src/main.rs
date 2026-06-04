#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]
#![warn(rust_2024_compatibility)]

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

use diesel::prelude::*;
use diesel::sqlite::SqliteConnection;

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
}

fn test_sqlite() {
    // Unsafe function to extract the library version
    let lib_version = unsafe { libsqlite3_sys::sqlite3_libversion_number() };
    println!("sqlite3 lib version: {lib_version:?}",);

    let database_url = std::env::var("DATABASE_URL_SQLITE").unwrap_or_else(|_| "main.db".into());
    let mut conn = SqliteConnection::establish(&database_url).unwrap();

    let sqlite_version = diesel::select(diesel::dsl::sql::<diesel::sql_types::Text>(
        "sqlite_version();",
    ))
    .get_result::<String>(&mut conn)
    .unwrap_or_else(|_| "Unknown".to_owned());

    println!("SQLite version query: {sqlite_version}")
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
