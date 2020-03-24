use std::{
    io::{self, Write},
    path::{Path, PathBuf},
};

use tempfile::tempdir;

use crate::{
    bundled_libraries,
    dependencies::DependencyStyle,
    fs::{self, File},
    source::SourceInfo,
    tools,
};

pub struct LemurTarget {
    pub project_path: PathBuf,
    pub source: SourceInfo,
    pub dependencies: DependencyStyle,
}

impl LemurTarget {
    pub fn run(&self) -> io::Result<()> {
        let working_dir = tempdir()?;
        let working_path = working_dir.path();

        bundled_libraries::unpack_lemur(&working_path)?;
        bundled_libraries::unpack_testez(&working_path)?;

        let runner_path = working_path.join("test-runner.lua");
        fs::write(&runner_path, bundled_libraries::test_runner())?;

        let entry_path = working_path.join("lemur-entry.lua");

        {
            let mut starter = File::create(&entry_path)?;

            writeln!(
                starter,
                "local RUNNER_PATH = \"{}\"",
                escape_for_lua_string(&runner_path)
            )?;

            let testez_path = working_path.join("testez");
            writeln!(
                starter,
                "local TESTEZ_PATH = \"{}\"",
                escape_for_lua_string(&testez_path)
            )?;

            if self.source.has_src_dir {
                let src_path = self.project_path.join("src");
                writeln!(
                    starter,
                    "local SRC_PATH = \"{}\"",
                    escape_for_lua_string(&src_path)
                )?;
            } else {
                return Err(io::Error::new(
                    io::ErrorKind::Other,
                    "Lemur requires that your project has a 'src' directory.",
                ));
            }

            match self.dependencies {
                DependencyStyle::None => {}

                DependencyStyle::Rotriever => {
                    let packages_path = escape_for_lua_string(&self.project_path.join("Packages"));

                    writeln!(starter, "local DEPS = {{")?;
                    writeln!(starter, "\tkind = \"rotriever\",")?;
                    writeln!(starter, "\tpackagesPath = \"{}\",", packages_path)?;
                    writeln!(starter, "}}")?;
                }

                DependencyStyle::GitSubmodules => {
                    writeln!(
                        starter,
                        "local DEPS = {{ kind = \"git-submodules\", modules = {{"
                    )?;

                    let modules_path = self.project_path.join("modules");
                    for entry in fs::read_dir(&modules_path)? {
                        let entry = entry?;
                        let path = entry.path();

                        if path.is_dir() {
                            let dep_name = path.file_name().unwrap().to_str().unwrap();
                            let source_info = SourceInfo::detect(&path);

                            if !source_info.has_src_dir {
                                log::warn!(
                                    "Skipping module {} as it has no src directory",
                                    dep_name
                                );
                                continue;
                            }

                            let src_path = escape_for_lua_string(&path.join("src"));
                            writeln!(starter, "\t{{ \"{}\", \"{}\" }},", src_path, dep_name)?;
                        }
                    }

                    writeln!(starter, "}} }}")?;
                }
            }

            writeln!(starter)?;
            write!(starter, "{}", bundled_libraries::lemur_entry())?;
        }

        tools::lua(&entry_path, &working_path);

        Ok(())
    }
}

fn escape_for_lua_string(path: &Path) -> String {
    let out = path.display().to_string();
    let out = out.replace('\\', "\\\\");
    out
}
