#![warn(rust_2018_idioms)]
#![warn(rust_2021_compatibility)]

// needed to avoid link errors even if we don't use it directly
#[allow(unused_extern_crates)]
extern crate openssl;

fn main() {
    let pq_lib_version = unsafe { pq_sys::PQlibVersion() };
    println!("pqlib version: {:?}", pq_lib_version);

    unsafe {
        pq_sys::PQinitSSL(1);
    }
}
