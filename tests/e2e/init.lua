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

	["run afterEach e2e with error in it block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("errorInItBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError ~= nil, "Expected 'While cleaning up...' msg to be shown when afterEach fails after it fails")
		end)
	end,

	["run afterEach e2e with failure in it block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("failureInItBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError ~= nil, "Expected 'While cleaning up...' msg to be shown when afterEach fails after it fails")
		end)
	end,

	["run afterEach e2e with failure in afterEach block"] = function()
		TestEZ.run(script:FindFirstChild("afterEachAfterFailure"):FindFirstChild("errorInAfterEachBlock"), function(results)
			assert(#results.errors == 1, "Expected one error, got " .. tostring(#results.errors))

			local afterEachError = string.find(results.errors[1], "afterEach threw an error as expected")
			assert(afterEachError ~= nil, "Expected afterEach to be reached after it throws an error")

			local cleaningUpError = string.find(results.errors[1], "While cleaning up the failed test another error was found")
			assert(cleaningUpError == nil, "Expected 'While cleaning up...' msg to not be shown when only afterEach fails")
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
