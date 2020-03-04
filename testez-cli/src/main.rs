mod bundled_libraries;
mod cli;
mod dependencies;
mod fs;
mod source;
mod targets;
mod test_place;
mod tools;
mod vfs;

use std::error::Error;

use structopt::StructOpt;

use cli::{GlobalOptions, Options, RunSubcommand, Subcommand, Target};
use dependencies::DependencyStyle;
use source::SourceInfo;
use targets::{LemurTarget, RobloxCliTarget};

fn main() {
    let options = Options::from_args();

    let env = env_logger::Env::new().default_filter_or("testez-cli=info");
    env_logger::Builder::from_env(env)
        .format_module_path(false)
        .format_timestamp(None)
        .format_indent(Some(8))
        .init();

    let result = match options.subcommand {
        Subcommand::Run(sub_options) => run(options.global, sub_options),
    };

    if let Err(err) = result {
        eprintln!("Error: {}", err);
        std::process::exit(1);
    }
}

fn run(_global: GlobalOptions, options: RunSubcommand) -> Result<(), Box<dyn Error>> {
    let mut path = options.path;
    if !path.is_absolute() {
        path = std::env::current_dir()?.join(path);
    }

    let dependencies = DependencyStyle::detect(&path)?;
    let source = SourceInfo::detect(&path);

    log::debug!("Dependency style: {:?}", dependencies);
    log::debug!("Source style: {:#?}", source);

    match options.target {
        Target::RobloxCli => {
            let target = RobloxCliTarget {
                project_path: path,
                source,
                dependencies,
                core_script_security: options.core_script_security,
            };

            target.run()?;
        }
        Target::Lemur => {
            let target = LemurTarget {
                project_path: path,
                source,
                dependencies,
            };

            target.run()?
        }
    }

    Ok(())
}
