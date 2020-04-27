-- luacheck: globals describe it fail
return function()
	describe("should fail", function()
		it("failing", function()
			fail("Failed")
		end)
	end)
end
