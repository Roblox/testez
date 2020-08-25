Often during development, you'll want to only run the test that's concerned with the specific code you're working on.

TestEZ provides the `SKIP()` and `FOCUS()` functions to either skip or focus the block that the call is contained in.

This mechanism does not work for `it` blocks; use `itSKIP` and `itFOCUS` instead. Code inside `it` blocks is not run until tests are executed, while `describe` blocks are run immediately to figure out what tests a project contains.

For example, you might want to run the tests targeting a specific method or two for a `DateTime` module:

`DateTime.spec.lua`
```lua
return function()
	describe("new", function()
		FOCUS()

		it("does really important things", function()
			-- This block will run!
		end)
	end)

	itFOCUS("has all methods we expect", function()
		-- Calling FOCUS() would be too late here, so we use itFOCUS instead.

		-- This block will run, too
	end)

	describe("Format()", function()
		it("formats things", function()
			-- This block will never run!
		end)
	end)
end
```

!!! warning
	`FOCUS` and `SKIP` are intended exclusively for development. It's not recommended that tests containing these calls are checked into version control.

	Future versions of TestEZ will be able to detect this when running in a CI system and fail tests to prevent that from happening.