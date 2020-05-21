--[[
	Contains the logic to run a test plan and gather test results from it.

	TestRunner accepts a TestPlan object, executes the planned tests, and
	produces a TestResults object. While the tests are running, the system's
	state is contained inside a TestSession object.
]]

local TestEnum = require(script.Parent.TestEnum)
local TestSession = require(script.Parent.TestSession)
local LifecycleHooks = require(script.Parent.LifecycleHooks)

local RUNNING_GLOBAL = "__TESTEZ_RUNNING_TEST__"

local TestRunner = {}

--[[
	Runs the given TestPlan and returns a TestResults object representing the
	results of the run.
]]
function TestRunner.runPlan(plan)
	local session = TestSession.new(plan)
	local lifecycleHooks = LifecycleHooks.new()

	local exclusiveNodes = plan:findNodes(function(node)
		return node.modifier == TestEnum.NodeModifier.Focus
	end)

	session.hasFocusNodes = #exclusiveNodes > 0

	TestRunner.runPlanNode(session, plan, lifecycleHooks)

	return session:finalize()
end

--[[
	Run the given test plan node and its descendants, using the given test
	session to store all of the results.
]]
function TestRunner.runPlanNode(session, planNode, lifecycleHooks)
	local function runCallback(callback, always, messagePrefix)
		local success = true
		local errorMessage
		-- Any code can check RUNNING_GLOBAL to fork behavior based on
		-- whether a test is running. We use this to avoid accessing
		-- protected APIs; it's a workaround that will go away someday.
		_G[RUNNING_GLOBAL] = true

		messagePrefix = messagePrefix or ""

		local originalEnvironment = getfenv(callback)
		local testEnvironment = setmetatable({}, { __index = originalEnvironment })
		for key, value in pairs(planNode.environment) do
			testEnvironment[key] = value
		end

		function testEnvironment.fail(message)
			if not message then
				message = "fail() was called"
			end
			errorMessage = debug.traceback(message, 2)
			success = false
		end

		setfenv(callback, testEnvironment)

		local nodeSuccess, nodeResult = xpcall(callback, debug.traceback)

		if planNode.errorMessage then
			success = false
			errorMessage = messagePrefix .. planNode.errorMessage
		end

		-- If a node threw an error, we prefer to use that message over
		-- one created by fail() if it was set.
		if not nodeSuccess then
			success = false
			errorMessage = messagePrefix .. nodeResult
		end

		_G[RUNNING_GLOBAL] = nil

		return success, errorMessage
	end

	local function runNode(childPlanNode)
		-- Errors can be set either via `error` propagating upwards or
		-- by a test calling fail([message]).

		for _, hook in pairs(lifecycleHooks:getPendingBeforeAllHooks()) do
			local success, errorMessage = runCallback(hook, false, "beforeAll hook: ")
			if not success then
				return false, errorMessage
			end
		end

		for _, hook in pairs(lifecycleHooks:getBeforeEachHooks()) do
			local success, errorMessage = runCallback(hook, false, "beforeEach hook: ")
			if not success then
				return false, errorMessage
			end
		end

		do
			local success, errorMessage = runCallback(childPlanNode.callback)
			if not success then
				return false, errorMessage
			end
		end

		for _, hook in pairs(lifecycleHooks:getAfterEachHooks()) do
			local success, errorMessage = runCallback(hook, true, "afterEach hook: ")
			if not success then
				return false, errorMessage
			end
		end

		return true, nil
	end

	lifecycleHooks:pushHooksFrom(planNode)

	for _, childPlanNode in ipairs(planNode.children) do
		local childResultNode = session:pushNode(childPlanNode)

		if childPlanNode.type == TestEnum.NodeType.It then
			if session:shouldSkip() then
				childResultNode.status = TestEnum.TestStatus.Skipped
			else
				local success, errorMessage = runNode(childPlanNode)

				if success then
					childResultNode.status = TestEnum.TestStatus.Success
				else
					childResultNode.status = TestEnum.TestStatus.Failure
					table.insert(childResultNode.errors, errorMessage)
				end
			end
		elseif childPlanNode.type == TestEnum.NodeType.Describe then
			TestRunner.runPlanNode(session, childPlanNode, lifecycleHooks)

			local status = TestEnum.TestStatus.Success

			-- Did we have an error trying build a test plan?
			if childPlanNode.loadError then
				status = TestEnum.TestStatus.Failure

				local message = "Error during planning: " .. childPlanNode.loadError

				table.insert(childResultNode.errors, message)
			else
				local skipped = true

				-- If all children were skipped, then we were skipped
				-- If any child failed, then we failed!
				for _, child in ipairs(childResultNode.children) do
					if child.status ~= TestEnum.TestStatus.Skipped then
						skipped = false

						if child.status == TestEnum.TestStatus.Failure then
							status = TestEnum.TestStatus.Failure
						end
					end
				end

				if skipped then
					status = TestEnum.TestStatus.Skipped
				end
			end

			childResultNode.status = status
		end

		session:popNode()
	end

	for _, hook in pairs(lifecycleHooks:getAfterAllHooks()) do
		runCallback(hook, true, "afterAll hook: ")
		-- errors in an afterAll hook are currently not caught
		-- or attributed to a set of child nodes
	end

	lifecycleHooks:popHooks()
end

return TestRunner