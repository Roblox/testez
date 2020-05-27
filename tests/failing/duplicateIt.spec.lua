-- luacheck: globals describe it

return function()
	describe("multiple it blocks with the same description", function()
		it("should raise an error", function()
		end)
		it("should raise an error", function()
		end)
	end)
end