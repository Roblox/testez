-- luacheck: globals describe it itSKIP SKIP
return function()
	itSKIP("skip a failing test", function()
		error("shouldn't happen")
	end)

	describe("skip a failing block", function()
		SKIP()

		it("shouldn't run", function()
			error("also shouldn't happen")
		end)
	end)
end