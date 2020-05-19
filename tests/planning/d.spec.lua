-- luacheck: globals describe it SKIP

return function()
	describe("test4", function()
		it("test5", function()
		end)

		it("test6", function()
		end)
	end)

	describe("test4", function()
		it("test5", function()
		end)

		it("test7", function()
		end)
	end)
end
