--[[
	Create a new environment with functions for defining the test plan structure
	using the given TestPlanBuilder.

	These functions illustrate the advantage of the stack-style tree navigation
	as state doesn't need to be passed around between functions or explicitly
	global.
]]
local TestEnum = require(script.Parent.TestEnum)

local TestEnvironment = {}

function TestEnvironment.new(builder, extraEnvironment)
	local env = {}

	if extraEnvironment then
		if type(extraEnvironment) ~= "table" then
			error(("Bad argument #2 to TestEnvironment.new. Expected table, got %s"):format(
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
		local node = builder:pushNode(phrase, TestEnum.NodeType.Describe, nodeModifier)

		local ok, err = pcall(callback)

		-- loadError on a TestPlan node is an automatic failure
		if not ok then
			node.loadError = err
		end

		builder:popNode()
	end

	function env.it(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It)

		node.callback = callback

		builder:popNode()
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
			local node = builder:pushNode(name .. "_" .. tostring(lifecyclePhaseId), nodeType)
			lifecyclePhaseId = lifecyclePhaseId + 1

			node.callback = callback

			builder:popNode()
		end
	end

	function env.itFOCUS(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Focus)

		node.callback = callback

		builder:popNode()
	end

	function env.itSKIP(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)

		node.callback = callback

		builder:popNode()
	end

	function env.itFIXME(phrase, callback)
		local node = builder:pushNode(phrase, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)

		warn("FIXME: broken test", node:getFullName())
		node.callback = callback

		builder:popNode()
	end

	function env.FIXME(optionalMessage)
		local currentNode = builder:getCurrentNode()
		warn("FIXME: broken test", currentNode:getFullName(), optionalMessage or "")

		currentNode.modifier = TestEnum.NodeModifier.Skip
	end

	function env.FOCUS()
		local currentNode = builder:getCurrentNode()

		currentNode.modifier = TestEnum.NodeModifier.Focus
	end

	function env.SKIP()
		local currentNode = builder:getCurrentNode()

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
		local currentNode = builder:getCurrentNode()

		currentNode.HACK_NO_XPCALL = true
	end

	env.step = env.it

	env.fit = env.itFOCUS
	env.xit = env.itSKIP
	env.fdescribe = env.describeFOCUS
	env.xdescribe = env.describeSKIP

	setmetatable(env, TestEnvironment)
	return env
end

return TestEnvironment