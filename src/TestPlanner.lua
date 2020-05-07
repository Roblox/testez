--[[
	Turns a series of specification functions into a test plan.

	Uses a TestPlanBuilder to keep track of the state of the tree being built.
]]
local TestPlan = require(script.Parent.TestPlan)

local TestPlanner = {}

--[[
	Create a new TestPlan from a list of specification functions.

	These functions should call a combination of `describe` and `it` (and their
	variants), which will be turned into a test plan to be executed.
]]
function TestPlanner.createPlan(specFunctions, testNamePattern, extraEnvironment)
	local plan = TestPlan.new(testNamePattern, extraEnvironment)

	for _, module in ipairs(specFunctions) do
		plan:addRoot(module.path, module.method)
	end

	return plan
end

return TestPlanner