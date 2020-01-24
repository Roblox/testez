use std::{io, path::Path};

use crate::vfs::Item;

pub fn unpack_lemur<P: AsRef<Path>>(path: P) -> io::Result<()> {
    static BINCODE: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/lemur.bincode"));

    let lemur: Item = bincode::deserialize(BINCODE).unwrap();
    lemur.unpack(path)
}

pub fn unpack_testez<P: AsRef<Path>>(path: P) -> io::Result<()> {
    static BINCODE: &[u8] = include_bytes!(concat!(env!("OUT_DIR"), "/testez.bincode"));

    let testez: Item = bincode::deserialize(BINCODE).unwrap();
    testez.unpack(path)
}

pub fn testez_rbxmx() -> &'static str {
    include_str!(concat!(env!("OUT_DIR"), "/testez.rbxmx"))
}

pub fn test_runner() -> &'static str {
    include_str!("test-runner.lua")
}

pub fn lemur_entry() -> &'static str {
    include_str!("lemur-entry.lua")
}
