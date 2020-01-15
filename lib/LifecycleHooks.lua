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
	Pushes uncalled beforeAll and afterAll hooks back up the stack
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

	pushHooksUp(TestEnum.NodeType.BeforeAll)
	pushHooksUp(TestEnum.NodeType.AfterAll)
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
		[TestEnum.NodeType.BeforeAll] = self:_getHooksOfTypeIncludingUncalledAtCurrentLevel(planNode.children, TestEnum.NodeType.BeforeAll),
		[TestEnum.NodeType.AfterAll] = self:_getHooksOfTypeIncludingUncalledAtCurrentLevel(planNode.children, TestEnum.NodeType.AfterAll),
		[TestEnum.NodeType.BeforeEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.BeforeEach),
		[TestEnum.NodeType.AfterEach] = self:_getHooksOfType(planNode.children, TestEnum.NodeType.AfterEach),
	})
end

function LifecycleHooks:getPendingBeforeHooks()

	return self:_getAndClearPendingHooks(TestEnum.NodeType.BeforeAll)
end

function LifecycleHooks:getAfterAllHooks()
	if self._stack:size() > 0 then
		return self:_getAndClearPendingHooks(TestEnum.NodeType.AfterAll)
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

function LifecycleHooks:getHooksInReverseStackOrder(key)

	assert(key ~= nil)

	local hooks = {}
	for _, level in ipairs(self._stack.data) do
		for _, hook in ipairs(level[key]) do
			table.insert(hooks, 1, hook)
		end
	end

	return hooks
end

function LifecycleHooks:getBeforeEachHooks()

	return self:getHooksInStackOrder(TestEnum.NodeType.BeforeEach)
end

function LifecycleHooks:getAfterEachHooks()

	return self:getHooksInReverseStackOrder(TestEnum.NodeType.AfterEach)
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
	Transfers uncalled beforeAll and afterAll hooks down the stack
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
		if type == TestEnum.NodeType.AfterAll then
			table.insert(hooks, 1, hook)
		else
			table.insert(hooks, hook)
		end
	end

	return hooks
end

return LifecycleHooks
