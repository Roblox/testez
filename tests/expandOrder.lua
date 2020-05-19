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
	["init.spec.lua afterAll can correctly undo changes"] = function()
		local initialized = false

		local plan = TestEZ.TestPlanner.createPlan({
			{
				method = function()
					assert(not initialized, "initialized was true in foo/a.spec")
				end,
				path = {'a.spec', 'foo'}
			},
			{
				method = function()
					assert(initialized, "initialized was false in foo/bar/b.spec")
				end,
				path = {'b.spec', 'bar', 'foo'}
			},
			{
				method = function()
					initialized = true

					-- luacheck: globals afterAll
					afterAll(function()
						print("!!!!!!!!!!!!!")
						initialized = false
					end)
				end,
				path = {'bar', 'foo'}
			},
			{
				method = function()
					assert(initialized, "initialized was false in foo/bar/c.spec")
				end,
				path = {'c.spec', 'bar', 'foo'}
			},
			{
				method = function()
					assert(not initialized, "initialized was true in foo/d.spec")
				end,
				path = {'d.spec', 'foo'}
			},
		})

		local results = TestEZ.TestRunner.runPlan(plan)
		assert(#results.errors == 0, "init test failed:\n" ..
			table.concat(results.errors, "\n"))
	end,
}