extern crate openssl; // needed to avoid link errors even if we don't use it directly
extern crate pq_sys;

fn main() {
    unsafe{ pq_sys::PQinitSSL(1); }
}
