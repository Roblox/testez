# TestEZ CLI
This is the CLI for [TestEZ](https://github.com/Roblox/testez), a BDD-style testing framework for Roblox.

TestEZ CLI bundles a copy of TestEZ and Lemur, making it easy to run on a project with very little additional setup.

## Installation
The recommended way to install TestEZ CLI is with [Foreman](https://github.com/rojo-rbx/foreman):

```toml
[tools]
testez = { source = "Roblox/testez", version = "0.2.0" }
```

It can also be compiled from source in this repository. Building from source requires [Rust](https://rust-lang.org) 1.40.0 or newer and [Rojo](https://github.com/rojo-rbx/rojo) 0.5.4 or newer.

```bash
# To build locally
cargo build

# To build and install
cargo install --path .
```

## Usage
TestEZ CLI relies on your project having a specific layout and currently **only functions for library or plugin-type projects.**

It assumes:

* Your source lives in a folder named `src`
* Your dependencies:
	* Are Git submodules contained in `modules/`
	* Or are Rotriever dependencies contained in `Packages/`
* If you have a `default.project.json` file, it should build your library, **not a test place**
* If targeting Lemur, `lua` is on your `PATH` and Lemur's dependencies are installed.
	* We recommend [hererocks](https://github.com/mpeterv/hererocks) for managing your Lua installation.
* If targeting Roblox CLI, `roblox-cli` and `rojo` are on your `PATH`.

Once set up, running tests is as simple as:

```bash
# Using Lemur (default)
testez run --target lemur

# Using Roblox-CLI (Roblox internal only for now)
testez run --target roblox-cli
```

## License
TestEZ CLI is available under the Apache 2.0 license. See [LICENSE](../LICENSE) for details.
