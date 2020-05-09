-- luacheck: globals describe it

return function()
	describe("with the same description", function()
		it("should not run this", function()
			error("this won't happen")
		end)
	end)

	describe("with the same description", function()
		it("should only run this test", function()
		end)
	end)
end