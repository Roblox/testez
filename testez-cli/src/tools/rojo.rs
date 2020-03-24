//! Interface to the user's Rojo installation.

use std::{path::Path, process::Command};

pub fn rojo_build(project_path: &Path, output_path: &Path) {
    let project_arg = project_path.to_str().unwrap();
    let output_arg = output_path.to_str().unwrap();

    log::trace!("Executing 'rojo build'");

    let status = Command::new("rojo")
        .args(&["build", &project_arg, "--output", &output_arg])
        .status()
        .expect("failed to execute Rojo; is it installed?");

    assert!(status.success(), "Rojo exited with an error.");
}
