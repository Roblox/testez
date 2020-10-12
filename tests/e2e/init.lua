local TestEZ = require(script.Parent.Parent.TestEZ)

local noOptReporter = {
	report = function()
	end,
}

return {
	["run expect-extend e2e"] = function()
		TestEZ.run(script:FindFirstChild("expect-extend"), function(results)
			assert(#results.errors == 0,
				"Expected no errors, got " .. tostring(results.errors[1]) ..
				" plus " .. tostring(#results.errors - 1) .. " more.")
		end)
	end,

	["run lifecycle e2e w/ filter for describe block"] = function()
		TestEZ.TestBootstrap:run({
			script:FindFirstChild("lifecycle"):FindFirstChild("testNameFilterDescribeBlock"),
		},
		noOptReporter,
		{
			testNamePattern = "super specific describe block",
		})
	end,

	["run lifecycle e2e w/ filter for file name"] = function()
		TestEZ.TestBootstrap:run({
			script:FindFirstChild("lifecycle"):FindFirstChild("testNameFilterFileName"),
		},
		noOptReporter,
		{
			testNamePattern = "specificFileName",
		})
	end,
}
