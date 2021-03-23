extern crate tar;
extern crate flate2;

use std::io::{self, Read};
use std::fs::{self, File};
use std::path::{Path, PathBuf};
use std::env;
use std::process;

fn decompress(tarpath: PathBuf, extract_path: PathBuf) -> io::Result<()> {
    use flate2::read::GzDecoder;
    use tar::Archive;

    let tarball = fs::File::open(tarpath)?;
    let decompressed = GzDecoder::new(tarball);
    let mut archive = Archive::new(decompressed);

    fs::create_dir_all(&extract_path)?;
    archive.unpack(&extract_path)?;

    Ok(())
}

fn compress(input_file: &str, output_file: PathBuf) -> io::Result<()> {
    use flate2::write::GzEncoder;
    use flate2::Compression;
    use tar::Builder;

    let file = File::create(&output_file)?;
    let mut encoder = GzEncoder::new(file, Compression::default());
    let mut builder = Builder::new(&mut encoder);

    builder.append_path(input_file)?;

    // scope Drop's builder, then encoder
    Ok(())
}

fn verify(res: io::Result<()>) {
    let _ = res.map_err(|e| {
        println!("error: {}", e);
        process::exit(1);
    });
}

fn main() {
    let pwd = env::current_dir().unwrap();
    let data = "./data.txt";
    let tarpath = Path::new(&pwd).join("data.tar.gz");
    let extractpath = Path::new(&pwd).join("output");
    verify(compress(data, tarpath.clone()));
    println!("Compressed data");

    verify(decompress(tarpath, extractpath));
    println!("Decompressed data");

    let mut f = File::open(Path::new(&pwd).join("output").join("data.txt")).unwrap();
    let mut text = String::new();
    f.read_to_string(&mut text).unwrap();

    assert_eq!(&text, "hi\n");
    println!("Verified data");
}
