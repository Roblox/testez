-- luacheck: globals describe it expect
return function()
	local function helper()
		expect(1).to.never.equal(2)
	end

	describe("from within a describe block", function()
		it("helpers should be able to access expect", function()
			helper()
		end)
	end)
end