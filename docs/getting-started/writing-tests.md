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