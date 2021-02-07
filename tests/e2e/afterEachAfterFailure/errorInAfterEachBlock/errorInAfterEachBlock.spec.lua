return function()
	describe("When an error occurs in an afterEach block", function()
		it("Should pass", function()
			expect(true).to.equal(true)
		end)

		afterEach(function()
			-- Cause a failure to be picked up by the test harness
			error("afterEach threw an error as expected")
		end)
	end)
end
