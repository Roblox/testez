## Inside Tests

### describe
```
describe(phrase, callback)
```

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

### it
```
it(phrase, callback)
```

This function creates a new 'it' block. These blocks correspond to the **behaviors** that should be expected of the thing you're testing.

For example:

```lua
it("should add 1 and 1", function()
	expect(1 + 1).to.equal(2)
end)
```

### itFOCUS and itSKIP
```
itFOCUS(phrase, callback)
itSKIP(phrase, callback)
```

These methods are special versions of `it` that automatically mark the `it` block as *focused* or *skipped*. They're necessary because `FOCUS` and `SKIP` can't be called inside `it` blocks!

### FOCUS
```
FOCUS()
```

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

!!! note
	`FOCUS` does not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change which tests will run.

### SKIP
```
SKIP()
```

This function works similarly to `FOCUS()`, except instead of marking a block as *focused*, it will mark a block as *skipped*, which stops any of the test assertions in the block from being executed.

!!!note
	`SKIP` does not work inside an `it` block. The bodies of these blocks aren't executed until the tests run, which is too late to change which tests will run.

### expect
```
expect(value)
```

Creates a new `Expectation`, used for testing the properties of the given value.

Expectations are intended to be read like English assertions. These are all true:

```lua
-- Equality
expect(1).to.equal(1)
expect(1).never.to.equal(2)

-- Approximate equality
expect(5).to.be.near(5 + 1e-8)
expect(5).to.be.near(5 - 1e-8)
expect(math.pi).never.to.be.near(3)

-- Optional limit parameter
expect(math.pi).to.be.near(3, 0.2)

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