*In the future, TestEZ will have pre-built model files for use within Roblox without other tools.*

### Method 1: Rojo (Roblox)
* Copy the `src` directory into your codebase
* Rename the folder to `TestEZ`
* Use [Rojo](https://github.com/LPGhatguy/rojo) to sync the files into a place

### Method 2: Lemur (CI Systems)
You can use [Lemur](https://github.com/LPGhatguy/Lemur) paired together with a regular Lua 5.1 interpreter to run tests written with TestEZ.

This is the best approach when testing Roblox Lua libraries using existing continuous integration systems like Travis-CI. We use this technique to run tests for [Rodux](https://github.com/Roblox/Rodux) and other libraries.