//! Simple in-memory representation of a filesystem that can be unpacked.
//!
//! Some parts of this code are used in the tool's build script mostly, while
//! other parts are used in the tool itself.

#![allow(unused)]

use std::{borrow::Cow, env, fs, io, path::Path};

use serde::{Deserialize, Serialize};

#[derive(Clone, Serialize, Deserialize)]
pub enum Item {
    File(File),
    Dir(Dir),
}

#[derive(Clone, Serialize, Deserialize)]
pub struct File {
    name: Cow<'static, str>,
    contents: Cow<'static, [u8]>,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Dir {
    name: Cow<'static, str>,
    children: Vec<Item>,
}

impl Item {
    pub fn rename<S: Into<String>>(&mut self, new_name: S) {
        match self {
            Item::File(file) => file.name = Cow::Owned(new_name.into()),
            Item::Dir(dir) => dir.name = Cow::Owned(new_name.into()),
        }
    }

    pub fn pack<P: AsRef<Path>>(input: P) -> io::Result<Item> {
        let is_build_script = env::var("CARGO_MANIFEST_DIR").is_ok();

        Self::pack_item(input.as_ref(), is_build_script)
    }

    fn pack_item(input: &Path, is_build_script: bool) -> io::Result<Item> {
        if is_build_script {
            println!("cargo:rerun-if-changed={}", input.display());
        }

        let name = input.file_name().unwrap().to_str().unwrap().to_owned();

        let meta = fs::metadata(input)?;
        if meta.is_file() {
            let contents = fs::read(input)?;

            Ok(Item::File(File {
                name: Cow::Owned(name),
                contents: Cow::Owned(contents),
            }))
        } else {
            let children = fs::read_dir(input)?
                .map(|entry| Self::pack_item(&entry?.path(), is_build_script))
                .collect::<Result<_, _>>()?;

            Ok(Item::Dir(Dir {
                name: Cow::Owned(name),
                children,
            }))
        }
    }

    pub fn unpack<P: AsRef<Path>>(&self, output: P) -> io::Result<()> {
        match self {
            Item::File(file) => {
                let file_path = output.as_ref().join(file.name.as_ref());
                fs::write(file_path, &file.contents)?;
            }
            Item::Dir(dir) => {
                let dir_path = output.as_ref().join(dir.name.as_ref());
                fs::create_dir(&dir_path)?;

                for child in &dir.children {
                    child.unpack(&dir_path)?;
                }
            }
        }

        Ok(())
    }
}
