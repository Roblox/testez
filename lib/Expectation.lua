--[[
	Allows creation of expectation statements designed for behavior-driven
	testing (BDD). See Chai (JS) or RSpec (Ruby) for examples of other BDD
	frameworks.

	The Expectation class is exposed to tests as a function called `expect`:

		expect(5).to.equal(5)
		expect(foo()).to.be.ok()

	Expectations can be negated using .never:

		expect(true).never.to.equal(false)

	Expectations throw errors when their conditions are not met.
]]

local Expectation = {}

--[[
	Default depth for deepEqual to recurse to before doing shallow comparisons
]]
local DEFAULT_MAXIMUM_RECURSIVE_DEPTH = 10

--[[
	These keys don't do anything except make expectations read more cleanly
]]
local SELF_KEYS = {
	to = true,
	be = true,
	been = true,
	have = true,
	was = true,
	at = true,
}

--[[
	These keys invert the condition expressed by the Expectation.
]]
local NEGATION_KEYS = {
	never = true,
}

--[[
	Extension of Lua's 'assert' that lets you specify an error level.
]]
local function assertLevel(condition, message, level)
	message = message or "Assertion failed!"
	level = level or 1

	if not condition then
		error(message, level + 1)
	end
end

--[[
	Returns a version of the given method that can be called with either . or :
]]
local function bindSelf(self, method)
	return function(firstArg, ...)
		if firstArg == self then
			return method(self, ...)
		else
			return method(self, firstArg, ...)
		end
	end
end

local function formatMessage(result, trueMessage, falseMessage)
	if result then
		return trueMessage
	else
		return falseMessage
	end
end

--[[
	Create a new expectation
]]
function Expectation.new(value)
	local self = {
		value = value,
		successCondition = true,
		condition = false
	}

	setmetatable(self, Expectation)

	self.a = bindSelf(self, self.a)
	self.an = self.a
	self.ok = bindSelf(self, self.ok)
	self.equal = bindSelf(self, self.equal)
	self.throw = bindSelf(self, self.throw)
	self.near = bindSelf(self, self.near)
	self.deepEqual = bindSelf(self, self.deepEqual)

	return self
end

function Expectation.__index(self, key)
	-- Keys that don't do anything except improve readability
	if SELF_KEYS[key] then
		return self
	end

	-- Invert your assertion
	if NEGATION_KEYS[key] then
		local newExpectation = Expectation.new(self.value)
		newExpectation.successCondition = not self.successCondition

		return newExpectation
	end

	-- Fall back to methods provided by Expectation
	return Expectation[key]
end

--[[
	Called by expectation terminators to reset modifiers in a statement.

	This makes chains like:

		expect(5)
			.never.to.equal(6)
			.to.equal(5)

	Work as expected.
]]
function Expectation:_resetModifiers()
	self.successCondition = true
end

--[[
	Assert that the expectation value is the given type.

	expect(5).to.be.a("number")
]]
function Expectation:a(typeName)
	local result = (type(self.value) == typeName) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		),
		("Expected value not of type %q, got value %q of type %s"):format(
			typeName,
			tostring(self.value),
			type(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is not nil
]]
function Expectation:ok()
	local result = (self.value ~= nil) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q to be non-nil"):format(
			tostring(self.value)
		),
		("Expected value %q to be nil"):format(
			tostring(self.value)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our expectation value is equal to another value
]]
function Expectation:equal(otherValue)
	local result = (self.value == otherValue) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value %q (%s), got %q (%s) instead"):format(
			tostring(otherValue),
			type(otherValue),
			tostring(self.value),
			type(self.value)
		),
		("Expected anything but value %q (%s)"):format(
			tostring(otherValue),
			type(otherValue)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

local function _deepEqualHelper(o1, o2, ignoreMetatables, remainingRecursions)
	local avoidLoops = {}
	local function recurse(t1, t2, recursionsLeft)
		if recursionsLeft <= 0 then
			warn("Reached maximal recursive depth on deep equality check. Reverting to == for check")
			return t1 == t2
		end
		-- compare value types
		if type(t1) ~= type(t2) then
			return false
		end

		-- Base case: compare simple values
		if type(t1) ~= "table" then
			return t1 == t2
		end
		-- Alternatively, use mt equality
		local mt = getmetatable(t1)
		if not ignoreMetatables and mt and mt.__eq then
			return t1 == t2
		end

		-- Now, on to tables.
		-- First, let's avoid looping forever.
		if avoidLoops[t1] then
			return avoidLoops[t1] == t2
		end
		avoidLoops[t1] = t2
		-- Copy keys from t2
		local t2keys = {}
		local t2tablekeys = {}
		for k, _ in pairs(t2) do
			if type(k) == "table" then
				table.insert(t2tablekeys, k)
			end
			t2keys[k] = true
		end
		-- Let's iterate keys from t1
		for k1, v1 in pairs(t1) do
			local v2 = t2[k1]
			if type(k1) == "table" then
				-- if key is a table, we need to find an equivalent one.
				local ok = false
				for i, tk in ipairs(t2tablekeys) do
					if _deepEqualHelper(k1, tk, ignoreMetatables, recursionsLeft - 1) and recurse(v1, t2[tk], recursionsLeft - 1) then
						table.remove(t2tablekeys, i)
						t2keys[tk] = nil
						ok = true
						break
					end
				end
				if not ok then
					return false
				end
			else
				-- t1 has a key which t2 doesn't have, fail.
				if v2 == nil then
					return false
				end
				t2keys[k1] = nil
				if not recurse(v1, v2, recursionsLeft - 1) then
					return false
				end
			end
		end
		-- if t2 has a key which t1 doesn't have, fail.
		if next(t2keys) then
			return false
		end
		return true
	end
	return recurse(o1, o2, remainingRecursions)
end

--[[
	Assert that our expectation value is deeply equal to another value
]]
function Expectation:deepEqual(otherValue, ignoreMetatables, maxRecursiveDepth)
	maxRecursiveDepth = maxRecursiveDepth or DEFAULT_MAXIMUM_RECURSIVE_DEPTH
	local result = _deepEqualHelper(self.value, otherValue, ignoreMetatables, maxRecursiveDepth)

	local message = formatMessage(self.successCondition,
		("Expected value %q (%s), got %q (%s) instead"):format(
			tostring(otherValue),
			type(otherValue),
			tostring(self.value),
			type(self.value)
		),
		("Expected anything but value %q (%s)"):format(
			tostring(otherValue),
			type(otherValue)
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end




--[[
	Assert that our expectation value is equal to another value within some
	inclusive limit.
]]
function Expectation:near(otherValue, limit)
	assert(type(self.value) == "number", "Expectation value must be a number to use 'near'")
	assert(type(otherValue) == "number", "otherValue must be a number")
	assert(type(limit) == "number" or limit == nil, "limit must be a number or nil")

	limit = limit or 1e-7

	local result = (math.abs(self.value - otherValue) <= limit) == self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected value to be near %f (within %f) but got %f instead"):format(
			otherValue,
			limit,
			self.value
		),
		("Expected value to not be near %f (within %f) but got %f instead"):format(
			otherValue,
			limit,
			self.value
		)
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

--[[
	Assert that our functoid expectation value throws an error when called
]]
function Expectation:throw()
	local ok, err = pcall(self.value)
	local result = ok ~= self.successCondition

	local message = formatMessage(self.successCondition,
		("Expected function to succeed, but it threw an error: %s"):format(
			tostring(err)
		),
		"Expected function to throw an error, but it did not."
	)

	assertLevel(result, message, 3)
	self:_resetModifiers()

	return self
end

return Expectation