
local function _pathify(obj)
	if type(obj) == "string" then
		return "[\"" .. tostring(obj) .. "\"]"
	else
		return "[" .. tostring(obj) .. "]"
	end
end

local function equalityWrapper(lhs, rhs, ignoreMetatables, shallow)
	local savedWarningMessage = ""
	local stopPrinting = false -- Flipped as soon as we find an inequality
	local lhsAddress, rhsAddress
	if type(lhs) == "table" then
		lhsAddress = tostring(lhs)
	end
	if type(lhs) == "table" then
		rhsAddress = tostring(rhs)
	end
	if type(lhs) ~= "table" and type(rhs) ~= "table" then
		-- We can stop now and give helpful information if necessary
		local equalityResult = lhs == rhs
		local sameType = type(lhs) == type(rhs)
		-- Check if different types to avoid confusing error messages that fail to distinguish between 2 and "2"
		local warningMessage = ""
		if not equalityResult then
			warningMessage = "LHS has value " .. tostring(lhs) .. " and RHS has value " .. tostring(rhs)
		end
		if not sameType then
			warningMessage = warningMessage .. ", different types: LHS " .. type(lhs) .. " and RHS " .. type(rhs)
		end
		return equalityResult, warningMessage
	end
	local recursedOnce = false
	local avoidLoops = {}
	local function recurse(t1, t2, p)

		if shallow and recursedOnce then
			return t1 == t2
		end
		recursedOnce = true

		if type(t1) ~= type(t2) then
			return false
		end

		if type(t1) ~= "table" then
			return t1 == t2
		end

		-- Use overloaded equality if we have it and it's specified that we should.
		local mt = getmetatable(t1)
		if not ignoreMetatables and mt and mt.__eq then
			return t1 == t2
		end

		-- Avoid looping forever.
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

		-- Iterate over t1's keys
		for k1, v1 in pairs(t1) do
			local v2 = t2[k1]
			-- t1 has a key which t2 doesn't have, fail.
			if v2 == nil then
				if not stopPrinting then
					if p == "" then
						savedWarningMessage = "LHS has a key that RHS does not have at " .. lhsAddress
					else
						savedWarningMessage = "LHS has a key that RHS does not have at " .. lhsAddress .. ": " .. p
					end
					stopPrinting = true
				end
				return false
			end
			-- t2 also has that key. We must now check that the associated values are equal.
			t2keys[k1] = nil
			local newPath = p
			newPath = newPath .. _pathify(k1)
			if not recurse(v1, v2, newPath) then
				if not stopPrinting then
					local warningMessage = "Different values at " .. newPath
					savedWarningMessage = warningMessage
					stopPrinting = true
				end
				return false
			end
		end
		-- t2 has a key which t1 doesn't have, fail.
		if next(t2keys) then
			if not stopPrinting then
				if p == "" then
					savedWarningMessage = "RHS has a key that LHS does not have at " .. rhsAddress
				else
					savedWarningMessage = "RHS has a key that LHS does not have at " .. rhsAddress .. ": " .. p
				end
				stopPrinting = true
			end
			return false
		end
		return true
	end
	local equalityResult = recurse(lhs, rhs, "")
	return equalityResult, savedWarningMessage
end

return equalityWrapper