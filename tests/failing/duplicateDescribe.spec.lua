-- luacheck: globals describe it

return function()
	describe("with the same description", function()
		it("should run this", function()
			error("this won't get overwritten")
		end)
	end)

	describe("with the same description", function()
		it("should also run this", function()
		end)
	end)
end