local SpyStats = {}
SpyStats.__index = SpyStats

function SpyStats:assertCalledWith(...)
	local len = select("#", ...)

	assert(self.valuesLength, len, "length of expected values differs from stored values")

	for i = 1, len do
		local expected = select(i, ...)

		assert(self.values[i] == expected, "value differs")
	end
end

function SpyStats:captureValues(...)
	local len = select("#", ...)
	local result = {}

	assert(self.valuesLength, len, "length of expected values differs from stored values")

	for i = 1, len do
		local key = select(i, ...)
		result[key] = self.values[i]
	end

	return result
end

local function createSpy(inner)
	local spyStats = {
		callCount = 0,
		values = {},
		valuesLength = 0,
	}

	setmetatable(spyStats, SpyStats)

	local function spyValue(...)
		spyStats.callCount = spyStats.callCount + 1
		spyStats.values = {...}
		spyStats.valuesLength = select("#", ...)

		if inner ~= nil then
			return inner(...)
		end
	end

	return spyValue, spyStats
end

return createSpy