# Contributing to TestEZ
Thanks for considering contributing to TestEZ! This guide has a few tips and guidelines to make contributing to the project as easy as possible.

## Bug Reports
Any bugs (or things that look like bugs) can be reported on the [GitHub issue tracker](https://github.com/Roblox/TestEZ/issues).

Make sure you check to see if someone has already reported your bug first! Don't fret about it; if we notice a duplicate we'll send you a link to the right issue!

## Feature Requests
If there are any features you think are missing from TestEZ, you can post a request in the [GitHub issue tracker](https://github.com/Roblox/TestEZ/issues).

Just like bug reports, take a peak at the issue tracker for duplicates before opening a new feature request.

## Working on TestEZ
To get started working on TestEZ, you'll need:
* Git
* Lua 5.1
* [LuaFileSystem](https://keplerproject.github.io/luafilesystem/) (`luarocks install luafilesystem`)
* [Luacheck](https://github.com/mpeterv/luacheck) (`luarocks install luacheck`)
* [LuaCov](https://keplerproject.github.io/luacov) (`luarocks install luacov`)

Make sure to clone the repository with submodules. You can do that to your existing repository with:

```sh
git submodule update --init
```

Finally, you can run all of TestEZ's tests with:

```sh
lua test/lemur.lua
```

Or, to generate a LuaCov coverage report:

```sh
lua -lluacov test/lemur.lua
luacov
```

If you're an engineer at Roblox, you can skip this setup and use Roblox-CLI. Make sure it's on your `PATH` and that you have a production Roblox Studio installation. You can then run:

```sh
./test/roblox-cli.sh
```

## Pull Requests
Before starting a pull request, open an issue about the feature or bug. This helps us prevent duplicated and wasted effort. These issues are a great place to ask for help if you run into problems!

Before you submit a new pull request, check:
* Code Style: Match the existing code!
* Changelog: Add an entry to [CHANGELOG.md](CHANGELOG.md)
* Luacheck: Run [Luacheck](https://github.com/mpeterv/luacheck) on your code, no warnings allowed!
* Tests: They all need to pass!

### Code Style
Try to match the existing code style! In short:

* Tabs for indentation
* Double quotes
* One statement per line

Eventually we'll have a tool to check these things automatically.

### Changelog
Adding an entry to [CHANGELOG.md](CHANGELOG.md) alongside your commit makes it easier for everyone to keep track of what's been changed.

Add a line under the "Current master" heading. When we make a new release, all of those bullet points will be attached to a new version and the "Current master" section will become empty again.

### Luacheck
We use [Luacheck](https://github.com/mpeterv/luacheck) for static analysis of Lua on all of our projects.

From the command line, just run `luacheck src` to check the TestEZ source.

You should get it working on your system, and then get a plugin for the editor you use. There are plugins available for most popular editors!

### Tests
When submitting a bug fix, create a test that verifies the broken behavior and that the bug fix works. This helps us avoid regressions!

We use [LuaCov](https://keplerproject.github.io/luacov) for keeping track of code coverage. We'd like it to be as close to 100% as possible, but it's not always easy.