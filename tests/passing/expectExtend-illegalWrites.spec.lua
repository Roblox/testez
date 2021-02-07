-- luacheck: globals describe beforeAll expect it

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

local ERROR_CANNOT_OVERWRITE = "Cannot overwrite matcher"

return function()
	describe("attempt to overwrite default", function()
		beforeAll(function()
			local success, message = pcall(function()
				expect.extend({
					-- This should throw since `ok` is a default matcher
					ok = noOptMatcher,
				})
			end)

			assert(success == false, "should have thrown")
			assert(message:match(ERROR_CANNOT_OVERWRITE), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

	describe("attempt to overwrite never", function()
		beforeAll(function()
			local success, message = pcall(function()
				expect.extend({
					-- This should throw since `never` is a default matcher
					never = noOptMatcher,
				})
			end)

			assert(success == false, "should have thrown")
			assert(message:match(ERROR_CANNOT_OVERWRITE), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

	describe("attempt to overwrite self", function()
		beforeAll(function()
			local success, message = pcall(function()
				expect.extend({
					-- This should throw since `a` is a default matcher
					a = noOptMatcher,
				})
			end)

			assert(success == false, "should have thrown")
			assert(message:match(ERROR_CANNOT_OVERWRITE), string.format("\nUnexpected error:\n%s", message))
		end)
	end)
end
