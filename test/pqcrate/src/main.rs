extern crate openssl; // needed to avoid link errors even if we don't use it directly
extern crate pq_sys;

fn main() {
    let pq_lib_version = unsafe { pq_sys::PQlibVersion() };
    println!("pqlib version: {:?}", pq_lib_version);

    unsafe{ pq_sys::PQinitSSL(1); }
}
