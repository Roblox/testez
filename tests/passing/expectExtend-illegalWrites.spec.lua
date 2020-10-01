-- luacheck: globals describe beforeAll expect

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

return function()
	describe("attempt to overwrite default", function()
		beforeAll(function()
			expect.extend({
				-- This should throw since `ok` is a default matcher
				ok = noOptMatcher,
			})
		end)

		it("SHOULD fail", function()
			local success, message = pcall(function()
				expect()
			end)

			assert(message:match("Cannot overwrite matcher"), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

	describe("attempt to overwrite never", function()
		beforeAll(function()
			expect.extend({
				-- This should throw since `never` is protected
				never = noOptMatcher,
			})
		end)

		it("SHOULD fail", function()
			local success, message = pcall(function()
				expect()
			end)

			assert(message:match("Cannot overwrite matcher"), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

	describe("attempt to overwrite self", function()
		beforeAll(function()
			expect.extend({
				-- This should throw since `a` is protected
				a = noOptMatcher,
			})
		end)

		it("SHOULD fail", function()
			local success, message = pcall(function()
				expect()
			end)

			assert(message:match("Cannot overwrite matcher"), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

	describe("attempt to start with _", function()
		beforeAll(function()
			expect.extend({
				-- This should throw since this starts with _
				_fooBar = noOptMatcher,
			})
		end)

		it("SHOULD fail", function()
			local success, message = pcall(function()
				expect()
			end)

			assert(message:match("Matchers cannot start with"), string.format("\nUnexpected error:\n%s", message))
		end)
	end)

end
