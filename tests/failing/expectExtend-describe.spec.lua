-- luacheck: globals describe expect

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

return function()
	describe("SHOULD NOT work in a describe block", function()
		expect.extend({
			test = noOptMatcher,
		})
	end)
end
