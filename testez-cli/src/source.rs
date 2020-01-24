//! Defines information about where a project's source is located.
//!
//! This is used to detect both the root project's source as well as
//! dependencies when run in some modes.

use std::path::Path;

#[derive(Debug)]
pub struct SourceInfo {
    /// Defines whether this project folder has a `default.project.json` file in
    /// it. If so, we should prefer using Rojo when possible.
    pub has_rojo_project: bool,

    /// Defines whether this project has a `src` folder inside of it. We can
    /// fall back to this for environments that can't take advantage of Rojo.
    pub has_src_dir: bool,
}

impl SourceInfo {
    pub fn detect<P: AsRef<Path>>(project_path: P) -> SourceInfo {
        let project_path = project_path.as_ref();

        let has_rojo_project = project_path.join("default.project.json").is_file();
        let has_src_dir = project_path.join("src").is_dir();

        Self {
            has_rojo_project,
            has_src_dir,
        }
    }
}
