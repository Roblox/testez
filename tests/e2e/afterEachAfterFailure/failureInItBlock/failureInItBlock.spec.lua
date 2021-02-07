return function()
	describe("When a failure occurs in an it block", function()
		it("Should fail", function()
			fail("Failure in it block")
		end)

		afterEach(function()
			-- Cause an error to be picked up by the test harness
			error("afterEach threw an error as expected")
		end)
	end)
end
