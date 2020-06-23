local TestEZ = script.Parent.Parent.TestEZ
local Context = require(TestEZ.Context)

return {
	["Context.new returns a new context"] = function()
		assert(Context.new(), "Context.new() returned nil")
	end,
	["context.foo returns nil if it wasn't set"] = function()
		local context = Context.new()
		assert(context.foo == nil, string.format("Got %s, expected nil", tostring(context.foo)))
	end,
	["context.foo returns the value from setting context.foo"] = function()
		local context = Context.new()
		context.foo = "BAR"
		assert(context.foo == "BAR", string.format("Got %s, expected BAR", tostring(context.foo)))
	end,
	["context.foo can't be set twice"] = function()
		local context = Context.new()
		context.foo = "foo"
		local success, _ = pcall(function()
			context.foo = "bar"
		end)
		assert(not success, "Expected second context.foo to error")
	end,
	["Context.new accepts a parent"] = function()
		local parent = Context.new()
		assert(Context.new(parent), "Context.new(parent) returned nil")
	end,
	["A child context can still read its parent values"] = function()
		local parent = Context.new()
		parent.foo = "BAR"
		local child = Context.new(parent)
		assert(child.foo == "BAR", string.format("Got %s, expected BAR", tostring(child.foo)))
	end,
	["A parent context can't read its child values"] = function()
		local parent = Context.new()
		local child = Context.new(parent)
		child.foo = "BAR"
		assert(parent.foo == nil, string.format("Got %s, expected nil", tostring(parent.foo)))
	end,
	["A child can't overwrite parent values"] = function()
		local parent = Context.new()
		parent.foo = "foo"
		local child = Context.new(parent)
		local success, _ = pcall(function()
			child.foo = "bar"
		end)
		assert(not success, "Expected setting child.foo to error")
	end,
	["A child won't see changes to the parent"] = function()
		local parent = Context.new()
		local child = Context.new(parent)
		parent.foo = "foo"
		assert(child.foo == nil, string.format("Got %s, expected nil", tostring(parent.foo)))
	end,
}
