local TestEZ = require(script.Parent.Parent.TestEZ)

local passing = script.Parent.passing
local failing = script.Parent.failing

local function check(test, pass)
	TestEZ.run(test, function(results)
		if pass then
			assert(#results.errors == 0,
				"Expected no errors, got " .. tostring(results.errors[1]) ..
				" plus " .. tostring(#results.errors - 1) .. " more.")
		else
			assert(#results.errors > 0, "Expected some errors, got none.")
		end
	end)
end

local tests = {}
for _, child in ipairs(passing:GetChildren()) do
	tests["Passing tests pass: " .. child.Name] = function()
		check(child, true)
	end
end
for _, child in ipairs(failing:GetChildren()) do
	tests["Failing tests fail: " .. child.Name] = function()
		check(child, false)
	end
end
return tests
