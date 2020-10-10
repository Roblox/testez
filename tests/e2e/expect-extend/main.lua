local TestEZ = require(script.Parent.Parent.TestEZ)

local tests = script.Parent.tests

return {
	["SHOULD work e2e"] = function()
		TestEZ.run(tests, function(results)
			assert(#results.errors == 0,
				"Expected no errors, got " .. tostring(results.errors[1]) ..
				" plus " .. tostring(#results.errors - 1) .. " more.")
		end)
	end,
}
