-- luacheck: globals describe xdescribe

return function()
	xdescribe("test1", function()
	end)

	describe("test2", function()
	end)
end
