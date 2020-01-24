//! Defines the CLI options for the project.

use std::{error::Error, fmt, path::PathBuf, str::FromStr};

use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct Options {
    #[structopt(flatten)]
    pub global: GlobalOptions,

    #[structopt(subcommand)]
    pub subcommand: Subcommand,
}

#[derive(Debug, StructOpt)]
pub struct GlobalOptions {}

#[derive(Debug, StructOpt)]
pub enum Subcommand {
    /// Run tests on a project using TestEZ.
    Run(RunSubcommand),
}

#[derive(Debug, StructOpt)]
pub struct RunSubcommand {
    /// Path to the root of the project to test.
    #[structopt(default_value = "")]
    pub path: PathBuf,

    /// What target to run tests in.
    ///
    /// Can be:
    /// - roblox-cli
    /// - lemur
    #[structopt(long)]
    pub target: Target,

    /// Whether to run tests at core script security.
    #[structopt(long = "as-core-script")]
    pub core_script_security: bool,
}

#[derive(Debug, Clone, Copy)]
pub enum Target {
    RobloxCli,
    Lemur,
}

impl FromStr for Target {
    type Err = TargetConvertError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value {
            "roblox-cli" => Ok(Self::RobloxCli),
            "lemur" => Ok(Self::Lemur),
            _ => Err(TargetConvertError(value.to_owned())),
        }
    }
}

#[derive(Debug, Clone)]
pub struct TargetConvertError(String);

impl fmt::Display for TargetConvertError {
    fn fmt(&self, out: &mut fmt::Formatter) -> fmt::Result {
        write!(
            out,
            "Invalid target {}, valid options are roblox-cli and lemur",
            self.0
        )
    }
}

impl Error for TargetConvertError {}
