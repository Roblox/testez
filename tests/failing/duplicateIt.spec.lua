-- luacheck: globals describe it

return function()
	describe("multiple it blocks with the same description", function()
		it("all get run", function()
		end)
		it("all get run", function()
			error("this shouldn't get overwritten")
		end)
		it("all get run", function()
		end)
	end)
end