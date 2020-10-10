local TestEZ = require(script.Parent.Parent.TestEZ)

return {
	["run all e2e"] = function()
		TestEZ.run(script, function(results)
			assert(#results.errors == 0,
				"Expected no errors, got " .. tostring(results.errors[1]) ..
				" plus " .. tostring(#results.errors - 1) .. " more.")
		end)
	end,
}
