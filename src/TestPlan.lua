--[[
	Represents a tree of tests that have been loaded but not necessarily
	executed yet.

	TestPlan objects are produced by TestPlanner and TestPlanBuilder.
]]

local TestEnum = require(script.Parent.TestEnum)

local TestPlan = {}

TestPlan.__index = TestPlan

--[[
	Create a new, empty TestPlan.
]]
function TestPlan.new()
	local self = {
		children = {}
	}

	setmetatable(self, TestPlan)

	return self
end

--[[
	Calls the given callback on all nodes in the tree, traversed depth-first.
]]
function TestPlan:visitAllNodes(callback, root, level)
	root = root or self
	level = level or 0

	for _, child in ipairs(root.children) do
		callback(child, level)

		self:visitAllNodes(callback, child, level + 1)
	end
end

local function constructNodeFullName(node)
	if node.parent then
		local parentPhrase = constructNodeFullName(node.parent)
		if parentPhrase then
			return parentPhrase .. " " .. node.phrase
		end
	end
	return node.phrase
end

--[[
	Creates a new node that would be suitable to insert into the TestPlan.
]]
function TestPlan.createNode(phrase, nodeType, nodeModifier)
	nodeModifier = nodeModifier or TestEnum.NodeModifier.None

	local node = {
		phrase = phrase,
		type = nodeType,
		modifier = nodeModifier,
		children = {},
		callback = nil,
		getFullName = constructNodeFullName
	}

	return node
end

--[[
	Visualizes the test plan in a simple format, suitable for debugging the test
	plan's structure.
]]
function TestPlan:visualize()
	local buffer = {}
	self:visitAllNodes(function(node, level)
		table.insert(buffer, (" "):rep(3 * level) .. node.phrase)
	end)
	return table.concat(buffer, "\n")
end

--[[
	Gets a list of all nodes in the tree for which the given callback returns
	true.
]]
function TestPlan:findNodes(callback)
	local results = {}
	self:visitAllNodes(function(node)
		if callback(node) then
			table.insert(results, node)
		end
	end)
	return results
end

return TestPlan