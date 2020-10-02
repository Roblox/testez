local TestEZ = require(script.Parent.Parent.TestEZ)

local function check(str, test)
	local plan = TestEZ.TestPlanner.createPlan({
		{
			-- This function environment hack is needed because the test
			-- function is not defined or required from within a test. This
			-- shouldn't come up in real tests.
			method = function()
				setfenv(test, getfenv())
				test()
			end,
			path = {"errorTypeTests"}
		}
	})

	local results = TestEZ.TestRunner.runPlan(plan)

	assert(#results.errors > 0, "Expected some errors, got none.")
	for _, err in ipairs(results.errors) do
		local find = string.find(err, str)
		assert(find, string.format("Expected errors containing [%s], found [%s]", str, err))
	end
end

return {
	["Error message should show up in output"] = function()
		check("FOO", function()
			error("FOO")
		end)
	end,
	["Erroring with an object should mention the object"] = function()
		check("table:", function()
			error({})
		end)
	end,
	["Erroring with an object with __tostring should show the string"] = function()
		check("FOO", function()
			local obj = setmetatable({}, {__tostring=function()
				return "FOO"
			end})
			error(obj)
		end)
	end,
}
