return function()
	describe("When an error occurs in an it block", function()
		it("Should error", function()
			error("Failure in it block")
		end)

		afterEach(function()
			-- Cause an error to be picked up by the test harness
			error("afterEach threw an error as expected")
		end)
	end)
end
