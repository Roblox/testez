local completeLifecycleOrderTests = require(script:FindFirstAncestor("lifecycle").completeLifecycleOrderTests)

return function()
	describe("file name", completeLifecycleOrderTests)
end
