<h1 align="center">TestEZ</h1>
<div align="center">
	<a href="https://travis-ci.org/Roblox/testez">
		<img src="https://api.travis-ci.org/Roblox/testez.svg?branch=master" alt="Travis-CI Build Status" />
	</a>
</div>

<div align="center">
	BDD-style Roblox Lua testing framework
</div>

<div>&nbsp;</div>

TestEZ can run within Roblox itself, as well as inside [Lemur](https://github.com/LPGhatguy/Lemur) for testing on CI systems.

We use TestEZ at Roblox for testing our apps, in-game core scripts, built-in Roblox Studio plugins, as well as libraries like [Roact](https://github.com/Roblox/roact) and [Rodux](https://github.com/Roblox/rodux).

It provides an API that can run all of your tests with a single method call as well as a more granular API that exposes each step of the pipeline.

## Installation
*In the future, TestEZ will have pre-built model files for use within Roblox without other tools.*

### Method 1: Rojo (Roblox)
* Copy the `lib` directory into your codebase
* Rename the folder to `TestEZ`
* Use [Rojo](https://github.com/LPGhatguy/rojo) to sync the files into a place

### Method 2: Lemur (CI Systems)
You can use [Lemur](https://github.com/LPGhatguy/Lemur) paired together with a regular Lua 5.1 interpreter to run tests written with TestEZ.

This is the best approach when testing Roblox Lua libraries using existing continuous integration systems like Travis-CI. We use this technique to run tests for [Rodux](https://github.com/Roblox/Rodux) and other libraries.

## Creating a Test Script
TestEZ provides two levels of granularity for creating a test script.

The easiest (and recommended) approach is to load the `TestBootstrap` module and `Reporters.TextReporter`. To run all the tests contained in the object `MY_TESTS`, it's just:

```lua
local TestBootstrap = require(TestEZ.TestBootstrap)
local TextReporter = require(TestEZ.Reporters.TextReporter)

TestBootstrap:run(MY_TESTS, TextReporter)
```

The method also returns information about the test run that can be used to take further action.

Alternatively, you can use the other APIs directly. See [the source of `TestBootstrap`](lib/TestBootstrap.lua) as well as [DESIGN.md](DESIGN.md) for details on how to accomplish that.

## Writing Tests
Create `.spec.lua` files (or Roblox objects with the `.spec` suffix) for each module you want to test. These modules should return a function that in turn calls functions from TestEZ.

A simple module and associated TestEZ spec might look like:

`Greeter.lua`
```lua
local Greeter = {}

function Greeter:greet(person)
	return "Hello, " .. person
end

return Greeter
```

`Greeter.spec.lua`
```lua
return function()
	local Greeter = require(script.Parent.Greeter)

	describe("greet", function()
		it("should include the customary English greeting", function()
			local greeting = Greeter:greet("X")
			expect(greeting:match("Hello")).to.be.ok()
		end)

		it("should include the person being greeted", function()
			local greeting = Greeter:greet("Joe")
			expect(greeting:match("Joe")).to.be.ok()
		end)
	end)
end
```

The functions `describe`, `it`, and `expect` are injected by TestEZ and automatically hook into the current testing context.

Every module is implicitly scoped according to its path, meaning the tree that the above test represents might be:

```
LuaChat
	Greeter
		greet
			[+] should include the customary English greeting
			[+] should include the person being greeted
```

## Debugging Tests
Often during development, you'll want to only run the test that's concerned with the specific code you're working on.

TestEZ provides the `SKIP()` and `FOCUS()` functions to either skip or focus the block that the call is contained in.

This mechanism does not work for `it` blocks, where you can instead use `itSKIP` and `itFOCUS`. This is because the code inside `it` blocks is not run until the test is executed.

For example, I might want to run the tests targeting a specific method for my `DateTime` module:

`DateTime.spec.lua`
```lua
return function()
	describe("ImportantFeature", function()
		FOCUS()

		it("does really important things", function()
			-- This callback *will* run!
		end)
	end)

	describe("Format", function()
		it("formats things", function()
			-- This callback will never run!
		end)
	end)
end
```

***`FOCUS` and `SKIP` are intended exclusively for development; future versions of TeztEZ will be able to detect this when running in a CI system and fail tests!***

## TestEZ Test API

### `describe(phrase, callback)`
This function creates a new `describe` block. These blocks correspond to the **things** that are being tested.

Put `it` blocks inside of `describe` blocks to describe what behavior should be correct.

For example:

```lua
describe("This cheese", function()
	it("should be moldy", function()
		expect(cheese.moldy).to.equal(true)
	end)
end)
```

### `it(phrase, callback)`
This function creates a new 'it' block. These blocks correspond to the **behaviors** that should be expected of the thing you're testing.

For example:

```lua
it("should add 1 and 1", function()
	expect(1 + 1).to.equal(2)
end)
```

### `FOCUS()`
When called inside a `describe` block, `FOCUS()` marks that block as *focused*. If there are any focused blocks inside your test tree, *only* focused blocks will be executed, and all other tests will be skipped.

When you're writing a new set of tests as part of a larger codebase, use `FOCUS()` while debugging them to reduce the amount of noise you need to scroll through.

For example:

```lua
describe("Secret Feature X", function()
	FOCUS()

	it("should do something", function()
	end)
end)

describe("Secret Feature Y", function()
	it("should do nothing", function()
		-- This code will not run!
	end)
end)
```

**Note: `FOCUS` will not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change the test plan.**

### `SKIP()`
This function works similarly to `FOCUS()`, except instead of marking a block as *focused*, it will mark a block as *skipped*, which stops any of the test assertions in the block from being executed.

**Note: `SKIP` will not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change the test plan.**

### `expect(value)`
Creates a new `Expectation`, used for testing the properties of the given value.

Expectations are intended to be read like English assertions. These are all true:

```lua
-- Equality
expect(1).to.equal(1)
expect(1).never.to.equal(2)

-- Nil checking
expect(1).to.be.ok()
expect(false).to.be.ok()
expect(nil).never.to.be.ok()

-- Type checking
expect(1).to.be.a("number")
expect(newproxy(true)).to.be.a("userdata")

-- Function throwing
expect(function()
	error("nope")
end).to.throw()

expect(function()
	-- I don't throw!
end).never.to.throw()
```

## Inspiration and Prior Work
The `describe` and `it` syntax in TestEZ is based on the [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) methodology, notably as implemented in RSpec (Ruby), busted (Lua), Mocha (JavaScript), and Ginkgo (Go).

The `expect` syntax is based on Chai, a JavaScript assertion library commonly used with Mocha. Similar expectation systems are also used in RSpec and Ginkgo, with slightly different syntax.

## Contributing
Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for information.

## License
TestEZ is available under the Apache 2.0 license. See [LICENSE](LICENSE) for details.