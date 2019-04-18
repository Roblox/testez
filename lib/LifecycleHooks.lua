local TestEnum = require(script.Parent.TestEnum)
local Stack = require(script.Parent.Stack)


local LifecycleHooks = {}
LifecycleHooks.__index = LifecycleHooks

function LifecycleHooks.new()
	local self = {}
	setmetatable(self, LifecycleHooks)
	self._stack = Stack.new()
	return self
end

--[[
	Pushes uncalled before and after hooks back up the stack
]]
function LifecycleHooks:popHooks()

	local popped = self._stack:pop()

	local function pushHooksUp(type)

		local back = self:_getBackOfStack()

		if not back then
			return
		end

		back[type] = popped[type]
	end

	pushHooksUp(TestEnum.NodeType.Before)
	pushHooksUp(TestEnum.NodeType.After)
end

function LifecycleHooks:pushHooksFrom(planNode)

	assert(planNode ~= nil)

	local lastTestNodeAtLevel

	for _, childNode in pairs(planNode.children) do
		if childNode.type == TestEnum.NodeType.It then
			lastTestNodeAtLevel = childNode
		end
	end

	self._stack:push({
		lastTestNodeAtLevel = lastTestNodeAtLevel,
		[TestEnum.NodeType.Before] = self:_getHooksOfTypeIncludingUncalledAtCurrentLevel(planNode.children, TestEnum.NodeType.Before),
		[TestEnum.NodeType.After] = self:_getHooksOfTypeIncludingUncalledAtCurrentLevel(planNode.children, TestEnum.NodeType.After),
		[TestEnum.NodeType.BeforeEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.BeforeEach),
		[TestEnum.NodeType.AfterEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.AfterEach),
	})
end

function LifecycleHooks:getPendingBeforeHooks()

	return self:_getAndClearPendingHooks(TestEnum.NodeType.Before)
end

function LifecycleHooks:getAfterHooksIfLastTestNodeAtLevel(childPlanNode)

	assert(childPlanNode ~= nil)

	if self._stack:size() > 0 and childPlanNode == self._stack:getBack().lastTestNodeAtLevel then

		return self:_getAndClearPendingHooks(TestEnum.NodeType.After)
	else
		return {}
	end
end

function LifecycleHooks:getHooksInStackOrder(key)

	assert(key ~= nil)

	local hooks = {}

	for _, level in ipairs(self._stack.data) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, hook)
		end
	end

	return hooks
end

function LifecycleHooks:getBeforeEachHooks()

	return self:getHooksInStackOrder(TestEnum.NodeType.BeforeEach)
end

function LifecycleHooks:getAfterEachHooks()

	return self:getHooksInStackOrder(TestEnum.NodeType.AfterEach)
end

--[[
	Return any hooks that have not yet been returned for this key and clear those hooks
]]
function LifecycleHooks:_getAndClearPendingHooks(key)

	assert(key ~= nil)

	if self._stack:size() > 0 then

		local back = self._stack:getBack()

		local hooks = back[key]

		back[key] = {}

		return hooks
	else
		return {}
	end

end


function LifecycleHooks:_getBackOfStack()

	return self._stack:size() > 0 and self._stack:getBack() or nil
end

function LifecycleHooks:_getHooksOfType(nodes, type)

	local hooks = {}

	for _, node in pairs(nodes) do
		if node.type == type then
			table.insert(hooks, node.callback)
		end
	end

	return hooks
end

--[[
	Transfers uncalled before and after hooks down the stack
]]
function LifecycleHooks:_getHooksOfTypeIncludingUncalledAtCurrentLevel(childNodes, type)
	local currentBack = self:_getBackOfStack()

	local hooks = {}

	if currentBack then

		for _, hook in pairs(currentBack[type]) do
			table.insert(hooks, hook)
		end

		currentBack[type] = {}
	end

	for _, hook in pairs(self:_getHooksOfType(childNodes, type)) do
		table.insert(hooks, hook)
	end

	return hooks
end

return LifecycleHooks