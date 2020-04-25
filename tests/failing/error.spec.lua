-- luacheck: globals describe it
return function()
	describe("should fail", function()
		it("failing", function()
			error("Failed")
		end)
	end)
end
