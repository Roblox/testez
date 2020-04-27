-- luacheck: globals describe it
return function()
	it("shouldn't run", function()
	end)

	error("planning")
end