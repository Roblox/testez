-- luacheck: globals describe beforeAll expect

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

local ERROR_CANNOT_OVERWRITE = "Cannot overwrite matcher"
local ERROR_CANNOT_START_WITH = "Matchers cannot start with"

local runTest = function(expectedError)
	return function()
		local success, message = pcall(function()
			expect()
		end)

		assert(success == false, "should have been thrown")
		assert(message:match(expectedError), string.format("\nUnexpected error:\n%s", message))
	end
end

return function()
	describe("WITH test", function()


		describe("attempt to overwrite default", function()
			beforeAll(function()
				expect.extend({
					-- This should throw since `ok` is a default matcher
					ok = noOptMatcher,
				})
			end)

			it("SHOULD fail with expected error message", runTest(ERROR_CANNOT_OVERWRITE))
		end)

		describe("attempt to overwrite never", function()
			beforeAll(function()
				expect.extend({
					-- This should throw since `never` is protected
					never = noOptMatcher,
				})
			end)

			it("SHOULD fail with expected error message", runTest(ERROR_CANNOT_OVERWRITE))
		end)

		describe("attempt to overwrite self", function()
			beforeAll(function()
				expect.extend({
					-- This should throw since `a` is protected
					a = noOptMatcher,
				})
			end)

			it("SHOULD fail with expected error message", runTest(ERROR_CANNOT_OVERWRITE))
		end)

		describe("attempt to start with _", function()
			beforeAll(function()
				expect.extend({
					-- This should throw since this starts with _
					_fooBar = noOptMatcher,
				})
			end)

			it("SHOULD fail with expected error message", runTest(ERROR_CANNOT_START_WITH))
		end)
	end)
end
