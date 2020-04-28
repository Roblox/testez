-- luacheck: globals describe it SKIP

return function()
	describe("test1", function()
	end)

	describe("test2", function()
		SKIP()
		it("test3", function()
		end)
	end)
end
