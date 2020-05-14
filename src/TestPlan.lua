--[[
	Represents a tree of tests that have been loaded but not necessarily
	executed yet.

	TestPlan objects are produced by TestPlanner and TestPlanBuilder.
]]

local TestEnum = require(script.Parent.TestEnum)
local Expectation = require(script.Parent.Expectation)

local function newEnvironment(currentNode, extraEnvironment)
	local env = {}

	if extraEnvironment then
		if type(extraEnvironment) ~= "table" then
			error(("Bad argument #2 to newEnvironment. Expected table, got %s"):format(
				typeof(extraEnvironment)), 2)
		end

		for key, value in pairs(extraEnvironment) do
			env[key] = value
		end
	end

	function env.describeFOCUS(phrase, callback)
		return env.describe(phrase, callback, TestEnum.NodeModifier.Focus)
	end

	function env.describeSKIP(phrase, callback)
		return env.describe(phrase, callback, TestEnum.NodeModifier.Skip)
	end

	function env.describe(phrase, callback, nodeModifier)
		local node = currentNode:addChild(phrase, TestEnum.NodeType.Describe, nodeModifier)
		node.callback = callback
		node:expand()
		return node
	end

	function env.it(phrase, callback, nodeModifier)
		local node = currentNode:addChild(phrase, TestEnum.NodeType.It, nodeModifier)
		node.callback = callback
		return node
	end

	-- Incrementing counter used to ensure that beforeAll, afterAll, beforeEach, afterEach have unique phrases
	local lifecyclePhaseId = 0

	local lifecycleHooks = {
		[TestEnum.NodeType.BeforeAll] = "beforeAll",
		[TestEnum.NodeType.AfterAll] = "afterAll",
		[TestEnum.NodeType.BeforeEach] = "beforeEach",
		[TestEnum.NodeType.AfterEach] = "afterEach"
	}

	for nodeType, name in pairs(lifecycleHooks) do
		env[name] = function(callback)
			local node = currentNode:addChild(name .. "_" .. tostring(lifecyclePhaseId), nodeType)
			lifecyclePhaseId = lifecyclePhaseId + 1

			node.callback = callback
			return node
		end
	end

	function env.itFOCUS(phrase, callback)
		return env.it(phrase, callback, TestEnum.NodeModifier.Focus)
	end

	function env.itSKIP(phrase, callback)
		return env.it(phrase, callback, TestEnum.NodeModifier.Skip)
	end

	function env.itFIXME(phrase, callback)
		local node = env.it(phrase, callback, TestEnum.NodeModifier.Skip)
		warn("FIXME: broken test", node:getFullName())
		return node
	end

	function env.FIXME(optionalMessage)
		warn("FIXME: broken test", currentNode:getFullName(), optionalMessage or "")

		currentNode.modifier = TestEnum.NodeModifier.Skip
	end

	function env.FOCUS()
		currentNode.modifier = TestEnum.NodeModifier.Focus
	end

	function env.SKIP()
		currentNode.modifier = TestEnum.NodeModifier.Skip
	end

	--[[
		These method is intended to disable the use of xpcall when running
		nodes contained in the same node that this function is called in.
		This is because xpcall breaks badly if the method passed yields.

		This function is intended to be hideous and seldom called.

		Once xpcall is able to yield, this function is obsolete.
	]]
	function env.HACK_NO_XPCALL()
		warn("HACK_NO_XPCALL is deprecated. It is now safe to yield in an " ..
			"xpcall, so this is no longer necessary. It can be safely deleted.")
	end

	env.fit = env.itFOCUS
	env.xit = env.itSKIP
	env.fdescribe = env.describeFOCUS
	env.xdescribe = env.describeSKIP

	env.expect = Expectation.new

	return env
end

local TestNode = {}
TestNode.__index = TestNode



local TestPlan = {}
TestPlan.__index = TestPlan

--[[
	Create a new, empty TestPlan.
]]
function TestPlan.new(testNamePattern, extraEnvironment)
	local plan = {
		children = {},
		testNamePattern = testNamePattern,
	}

	local Node = {}
	Node.__index = Node

	function Node.new(phrase, nodeType, nodeModifier)
		nodeModifier = nodeModifier or TestEnum.NodeModifier.None

		local node = {
			phrase = phrase,
			type = nodeType,
			modifier = nodeModifier,
			children = {},
			callback = nil,
		}

		node.environment = newEnvironment(node, extraEnvironment)
		return setmetatable(node, Node)
	end

	function Node:addChild(phrase, nodeType, nodeModifier)
		if nodeType == TestEnum.NodeType.It then
			for _, child in pairs(self.children) do
				if child.phrase == phrase then
					error("Duplicate it block found: " .. child:getFullName())
				end
			end
		end

		if testNamePattern and (nodeModifier == nil or nodeModifier == TestEnum.NodeModifier.None) then
			local name = self:getFullName() .. " " .. phrase
			if name:match(testNamePattern) then
				nodeModifier = TestEnum.NodeModifier.Focus
			else
				nodeModifier = TestEnum.NodeModifier.Skip
			end
		end
		local child = Node.new(phrase, nodeType, nodeModifier)
		child.parent = self
		table.insert(self.children, child)
		return child
	end

	function Node:getFullName()
		if self.parent and self.parent.getFullName then
			local parentPhrase = self.parent:getFullName()
			if parentPhrase then
				return parentPhrase .. " " .. self.phrase
			end
		end
		return self.phrase
	end

	function Node:expand()
		local originalEnv = getfenv(self.callback)
		local callbackEnv = setmetatable({}, { __index = originalEnv })
		for key, value in pairs(self.environment) do
			callbackEnv[key] = value
		end
		setfenv(self.callback, callbackEnv)

		local success, result = xpcall(self.callback, function(err)
			return err .. "\n" .. debug.traceback()
		end)

		if not success then
			self.loadError = result
		end
	end

	plan.Node = Node

	return setmetatable(plan, TestPlan)
end

function TestPlan:addChild(phrase, nodeType, nodeModifier)
	if self.testNamePattern and (nodeModifier == nil or nodeModifier == TestEnum.NodeModifier.None) then
		if phrase:match(self.testNamePattern) then
			nodeModifier = TestEnum.NodeModifier.Focus
		else
			nodeModifier = TestEnum.NodeModifier.Skip
		end
	end
	local child = self.Node.new(phrase, nodeType, nodeModifier)
	child.parent = self
	table.insert(self.children, child)
	return child
end

--[[

]]
function TestPlan:addRoot(path, method)
	local curNode = self
	for i = #path, 1, -1 do
		local nextNode = nil

		for _, child in ipairs(curNode.children) do
			if child.phrase == path[i] then
				nextNode = child
				break
			end
		end

		if nextNode == nil then
			nextNode = curNode:addChild(path[i], TestEnum.NodeType.Describe)
		end

		curNode = nextNode
	end

	curNode.callback = method
	curNode:expand()
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