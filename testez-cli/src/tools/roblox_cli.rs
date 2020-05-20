//! Interface to Roblox-CLI.

use std::{path::Path, process::Command};

use roblox_install::RobloxStudio;

pub fn roblox_cli_run(place_path: &Path, entrypoint_path: &str, as_core_script: bool) {
    let place_arg = place_path.to_str().unwrap();

    log::trace!("Executing 'roblox-cli run'");

    let mut command = Command::new("roblox-cli");
    command.args(&[
        "run",
        "--load.place",
        &place_arg,
        "--entrypoint",
        entrypoint_path,
    ]);

    if let Ok(install_location) = RobloxStudio::locate() {
        let content_path_arg = install_location.content_path().to_str().unwrap();
        command.arg("--assetFolder");
        command.arg(&content_path_arg);
    }

    if as_core_script {
        command.arg("--load.asRobloxScript");
    }

    let status = command
        .status()
        .expect("failed to execute Roblox-CLI; is it installed?");

    assert!(status.success(), "Roblox-CLI exited with an error.");
}
