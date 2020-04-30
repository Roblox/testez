--[[
	Turns a series of specification functions into a test plan.

	Uses a TestPlanBuilder to keep track of the state of the tree being built.
]]

local TestEnum = require(script.Parent.TestEnum)
local TestPlanBuilder = require(script.Parent.TestPlanBuilder)
local TestEnvironment = require(script.Parent.TestEnvironment)

local TestPlanner = {}

local function buildPlan(builder, module, env)
	local currentEnv = getfenv(module.method)

	for key, value in pairs(env) do
		currentEnv[key] = value
	end

	local nodeCount = #module.path

	-- Dive into auto-named nodes for this module
	for i = nodeCount, 1, -1 do
		local name = module.path[i]
		builder:pushNode(name, TestEnum.NodeType.Describe)
	end

	local ok, err = xpcall(module.method, function(err)
		return err .. "\n" .. debug.traceback()
	end)

	-- This is an error outside of any describe/it blocks.
	-- We attach it to the node we generate automatically per-file.
	if not ok then
		local node = builder:getCurrentNode()
		node.loadError = err
	end

	-- Back out of auto-named nodes
	for _ = 1, nodeCount do
		builder:popNode()
	end
end

--[[
	Create a new TestPlan from a list of specification functions.

	These functions should call a combination of `describe` and `it` (and their
	variants), which will be turned into a test plan to be executed.
]]
function TestPlanner.createPlan(specFunctions, testNamePattern, extraEnvironment)
	local builder = TestPlanBuilder.new()
	builder.testNamePattern = testNamePattern
	local env = TestEnvironment.new(builder, extraEnvironment)

	for _, module in ipairs(specFunctions) do
		buildPlan(builder, module, env)
	end

	return builder:finalize()
end

return TestPlanner