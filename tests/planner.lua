local TestEZ = script.Parent.Parent.TestEZ
local TestPlanner = require(TestEZ.TestPlanner)
local TestBootstrap = require(TestEZ.TestBootstrap)
local TestEnum = require(TestEZ.TestEnum)

local testRoot = script.Parent.planning

local function verifyPlan(plan, expected, notSkip)
	local nodes = plan:findNodes(function(node)
		return (not notSkip) or (node.modifier ~= TestEnum.NodeModifier.Skip)
	end)

	local nodeNames = {}
	for _, node in ipairs(nodes) do
		local name = node:getFullName()
		if nodeNames[name] then
			nodeNames[name] = nodeNames[name] + 1
		else
			nodeNames[name] = 1
		end
	end

	for _, name in ipairs(expected) do
		if nodeNames[name] then
			nodeNames[name] = nodeNames[name] - 1
		else
			nodeNames[name] = -1
		end
	end

	local pass = true
	local message = ""

	for name, count in pairs(nodeNames) do
		if count < 0 then
			pass = false
			message = message .. string.format("expected name [%s] not found, ", name)
		elseif count > 0 then
			pass = false
			message = message .. string.format("additional name [%s] found, ", name)
		end
	end

	return pass, message
end

return {
	["it should build the full plan with no arguments"] = function()
		local modules = TestBootstrap:getModules(testRoot)
		local plan = TestPlanner.createPlan(modules)
		assert(verifyPlan(plan, {
			"planning",
			"planning a",
			"planning a test1",
			"planning a test2",
			"planning b",
			"planning b test1",
			"planning b test2",
			"planning b test2 test3",
			"planning d",
			"planning d test4",
			"planning d test4 test5",
			"planning d test4 test6",
			"planning d test4",  -- Order doesn't actually matter for this test.
			"planning d test4 test5",
			"planning d test4 test7",
		}))
	end,
	["it should mark skipped tests as skipped"] = function()
		local modules = TestBootstrap:getModules(testRoot)
		local plan = TestPlanner.createPlan(modules)
		assert(verifyPlan(plan, {
			"planning",
			"planning a",
			"planning a test2",
			"planning b",
			"planning b test1",
			"planning b test2 test3", -- This isn't marked skip, its parent is
			"planning d",
			"planning d test4",
			"planning d test4 test5",
			"planning d test4 test6",
			"planning d test4",  -- Order doesn't actually matter for this test.
			"planning d test4 test5",
			"planning d test4 test7",
		}, true))
	end,
	["it should skip tests that don't match the filter"] = function()
		local modules = TestBootstrap:getModules(testRoot)
		local plan = TestPlanner.createPlan(modules, "test2")
		assert(verifyPlan(plan, {
			"planning a test2",
			"planning b test2 test3", -- Gets focus because only its parent is skip
		}, true))
	end,
}