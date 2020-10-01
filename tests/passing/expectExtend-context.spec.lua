-- luacheck: globals describe beforeAll expect it

local noOptMatcher = function(_received, _expected)
	return {
		message = "",
		pass = true,
	}
end

return function()
	beforeAll(function()
		expect.extend({
			scope_0 = noOptMatcher,
		})
	end)

	it("SHOULD inherit from previous beforeAll", function()
		assert(expect().scope_0, "should have scope_0")
	end)

	describe("scope 1", function()
		beforeAll(function()
			expect.extend({
				scope_1 = noOptMatcher,
			})
		end)

		it("SHOULD inherit from previous beforeAll", function()
			assert(expect().scope_1, "should have scope_1")
		end)

		it("SHOULD inherit from previous root level beforeAll", function()
			assert(expect().scope_0, "should have scope_0")
		end)

		it("SHOULD NOT inherit scope 2", function()
			assert(expect().scope_2 == nil, "should not have scope_0")
		end)

		describe("scope 2", function()
			beforeAll(function()
				expect.extend({
					scope_2 = noOptMatcher,
				})
			end)

			it("SHOULD inherit from previous beforeAll in scope 2", function()
				assert(expect().scope_2, "should have scope_2")
			end)

			it("SHOULD inherit from previous beforeAll in scope 1", function()
				assert(expect().scope_1, "should have scope_1")
			end)

			it("SHOULD inherit from previous beforeAll in scope 0", function()
				assert(expect().scope_0, "should have scope_0")
			end)
		end)
	end)

	it("SHOULD NOT inherit from scope 1", function()
		assert(expect().scope_1 == nil, "should not have scope_1")
	end)
end
