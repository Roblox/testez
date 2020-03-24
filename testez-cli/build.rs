use std::{env, fs::File, path::Path, process::Command};

#[path = "src/vfs.rs"]
mod vfs;

fn main() {
    println!("Path: {}", env::var("PATH").unwrap());

    let out_dir = env::var("OUT_DIR").unwrap();
    let framework_out_path = Path::new(&out_dir).join("testez.rbxmx");

    let build_output_arg = framework_out_path
        .to_str()
        .expect("output path had invalid Unicode");

    let status = Command::new("rojo")
        .args(&["build", "..", "--output", &build_output_arg])
        .status()
        .expect("could not run Rojo");

    assert!(status.success(), "Rojo did not execute successfully");

    pack_library("../modules/lemur/lib", "lemur");
    pack_library("../src", "testez");
}

fn pack_library<P: AsRef<Path>>(in_path: P, name: &str) {
    let out_dir = env::var("OUT_DIR").unwrap();

    let mut out_path = Path::new(&out_dir).join(name);
    out_path.set_extension("bincode");

    let out_file = File::create(&out_path).unwrap();

    let mut packed = vfs::Item::pack(in_path.as_ref()).unwrap();
    packed.rename(name);

    bincode::serialize_into(out_file, &packed).unwrap();
}
