local completeLifecycleOrderTests = require(script:FindFirstAncestor("lifecycle").completeLifecycleOrderTests)

return function()
	describe("never run", function()
		it("SHOULD FAIL", function()
			fail("This should have never ran. Check testNamePattern")
		end)
	end)

	describe("super specific describe block", completeLifecycleOrderTests)
end
