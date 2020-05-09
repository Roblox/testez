-- luacheck: globals describe it SKIP

return function()
	describe("test4", function()
		it("test5", function()
		end)

		it("test6", function()
		end)
	end)

	describe("test4", function()
		-- Duplicate describe blocks should get merged.
		it("test5", function()
			-- Duplicate it blocks will get overwritten.
		end)

		it("test7", function()
		end)
	end)
end
