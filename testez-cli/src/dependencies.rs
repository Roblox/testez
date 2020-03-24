//! Defines how to handle the different ways that projects using TestEZ-CLI can
//! have their dependencies configured.
//!
//! We support three schemes:
//! - None. No dependencies were detected.
//! - Rotriever. Dependencies are in `Packages`
//! - Git submodules. Dependencies are in `modules/*/src`.
//!
//! If we don't detect one of these styles, we assume the project has no
//! dependencies.

use std::{io, path::Path};

#[derive(Debug)]
pub enum DependencyStyle {
    None,
    Rotriever,
    GitSubmodules,
}

impl DependencyStyle {
    pub fn detect<P: AsRef<Path>>(project_path: P) -> io::Result<DependencyStyle> {
        let project_path = project_path.as_ref();

        let packages_path = project_path.join("Packages");
        if packages_path.is_dir() {
            return Ok(DependencyStyle::Rotriever);
        }

        let modules_path = project_path.join("modules");
        if modules_path.is_dir() {
            return Ok(DependencyStyle::GitSubmodules);
        }

        Ok(DependencyStyle::None)
    }
}
