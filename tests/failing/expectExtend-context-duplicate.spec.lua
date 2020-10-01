-- luacheck: globals describe beforeAll expect

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

return function()
	beforeAll(function()
		expect.extend({
			customMatcher = noOptMatcher,
		})
	end)

	describe("redefine matcher", function()
		beforeAll(function()
			expect.extend({
				-- This should throw since we are redefining the same matcher
				customMatcher = noOptMatcher,
			})
		end)
	end)
end
