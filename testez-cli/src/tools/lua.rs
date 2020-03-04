use std::{env, path::Path, process::Command};

pub fn lua(script_path: &Path, lemur_path: &Path) {
    let script_arg = script_path.to_str().unwrap();

    let path_to_add = format!(
        "{}/?.lua;{}/?/init.lua",
        lemur_path.display(),
        lemur_path.display(),
    );

    let lua_path = match env::var("LUA_PATH") {
        Ok(existing) => format!("{};{}", path_to_add, existing),
        Err(_) => path_to_add,
    };

    log::trace!("Executing 'lua'");

    let status = Command::new("lua")
        .args(&[&script_arg])
        .env("LUA_PATH", lua_path)
        .status()
        .expect("failed to execute Lua; is it installed?");

    assert!(status.success(), "Lua exited with an error.");
}
