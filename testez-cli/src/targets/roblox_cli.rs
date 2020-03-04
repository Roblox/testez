use std::{
    io::{self, BufReader, BufWriter},
    path::PathBuf,
};

use snafu::Snafu;
use tempfile::tempdir;

use crate::{
    dependencies::DependencyStyle,
    fs::File,
    source::SourceInfo,
    test_place::{TestPlace, TestPlaceInput},
    tools,
};

pub struct RobloxCliTarget {
    pub project_path: PathBuf,
    pub source: SourceInfo,
    pub dependencies: DependencyStyle,
    pub core_script_security: bool,
}

impl RobloxCliTarget {
    pub fn run(&self) -> Result<(), Error> {
        let place_folder = tempdir()?;

        let built_project_path = place_folder.path().join("BuiltProject.rbxmx");
        let built_deps_path = place_folder.path().join("Dependencies.rbxmx");
        let place_path = place_folder.path().join("TestPlace.rbxlx");

        log::trace!("Using temporary place path {}", place_path.display());

        log::debug!("Building project source...");
        if self.source.has_rojo_project {
            tools::rojo_build(&self.project_path, &built_project_path);
        } else if self.source.has_src_dir {
            let src_path = self.project_path.join("src");
            tools::rojo_build(&src_path, &built_project_path);
        } else {
            return Err(Error::NoSource);
        }

        log::debug!("Building project dependencies...");
        let deps = match self.dependencies {
            DependencyStyle::None => None,

            DependencyStyle::Rotriever => {
                let packages_path = self.project_path.join("Packages");
                tools::rojo_build(&packages_path, &built_deps_path);

                let deps_file = BufReader::new(File::open(&built_deps_path)?);
                Some(rbx_xml::from_reader_default(deps_file)?)
            }

            DependencyStyle::GitSubmodules => {
                // TODO: Enumerate modules instead of assuming it can build as a
                // Rojo project as-is.

                let modules_path = self.project_path.join("modules");
                tools::rojo_build(&modules_path, &built_deps_path);

                let deps_file = BufReader::new(File::open(&built_deps_path)?);
                Some(rbx_xml::from_reader_default(deps_file)?)
            }
        };

        let source_file = BufReader::new(File::open(&built_project_path)?);
        let source = rbx_xml::from_reader_default(source_file)?;

        log::debug!("Generating test place...");
        let test_place = TestPlace::generate(TestPlaceInput {
            source,
            dependencies: deps,
            core_script_security: self.core_script_security,
        });
        let place_file = BufWriter::new(File::create(&place_path)?);

        let test_place_children = test_place
            .tree
            .get_instance(test_place.tree.get_root_id())
            .unwrap()
            .get_children_ids();
        rbx_xml::to_writer_default(place_file, &test_place.tree, test_place_children)?;

        log::debug!("Starting test runner...");
        tools::roblox_cli_run(
            &place_path,
            test_place.entrypoint_path,
            self.core_script_security,
        );

        Ok(())
    }
}

#[derive(Debug, Snafu)]
pub enum Error {
    #[snafu(display("{}", source))]
    Io { source: io::Error },

    #[snafu(display("{}", source))]
    XmlDecode { source: rbx_xml::DecodeError },

    #[snafu(display("{}", source))]
    XmlEncode { source: rbx_xml::EncodeError },

    #[snafu(display("No source code found."))]
    NoSource,
}

impl From<io::Error> for Error {
    fn from(source: io::Error) -> Self {
        Self::Io { source }
    }
}

impl From<rbx_xml::DecodeError> for Error {
    fn from(source: rbx_xml::DecodeError) -> Self {
        Self::XmlDecode { source }
    }
}

impl From<rbx_xml::EncodeError> for Error {
    fn from(source: rbx_xml::EncodeError) -> Self {
        Self::XmlEncode { source }
    }
}
