local TestEZ = require(script.Parent.Parent.TestEZ)

return {
	["init.spec.lua is run before children are expanded"] = function()
		local initialized = false

		local plan = TestEZ.TestPlanner.createPlan({
			{
				method = function()
					assert(initialized, "init.spec was not called before bar.spec")
				end,
				path = {'bar.spec', 'foo'}
			},
			{
				method = function()
					initialized = true
				end,
				path = {'foo'}
			},
		})

		local results = TestEZ.TestRunner.runPlan(plan)
		assert(#results.errors == 0, "init test failed: " .. tostring(results.errors[1]))
	end,
}