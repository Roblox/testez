//! Interface to Roblox-CLI.

use log;
use std::{
    path::Path,
    process::{self, Command},
};

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

    let install = RobloxStudio::locate();
    if let Ok(install_location) = install {
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

    if !status.success() {
        log::error!("Roblox-CLI exited with an error");
        process::exit(1);
    } else {
        process::exit(0);
    }
}
