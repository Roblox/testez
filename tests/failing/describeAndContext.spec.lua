-- luacheck: globals describe

return function()
	describe("this shouldn't be able to access context", function(context)
		context.foo = "bar"
	end)
end
