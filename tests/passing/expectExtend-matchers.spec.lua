-- luacheck: globals describe beforeAll expect it

local customEqualMatcher = function(received, expected)
	local pass = received == expected
	if pass then
		return {
			message = "custom failure message (not)",
			pass = true,
		}
	else
		return {
			message = "custom failure message",
			pass = false,
		}
	end
end

return function()
	it("SHOULD have custom matcher when defined in `it` block", function()
		expect.extend({
			customEqual = customEqualMatcher,
		})

		assert(expect().customEqual, "customEqual should exist")
	end)

	describe("WHEN defining custom matcher in describe block", function()
		beforeAll(function()
			expect.extend({
				customEqual = customEqualMatcher,
			})
		end)

		describe("WHEN NOT inverting the expression", function()
			it("SHOULD pass as expected", function()
				expect("hello").customEqual("hello")
			end)

			it("SHOULD fail as expected", function()
				local success = pcall(function()
					expect("hello").customEqual("world")
				end)

				assert(success == false, "did not fail like expected")
			end)
		end)

		describe("WHEN inverting the expression", function()
			it("SHOULD pass as expected", function()
				expect("hello").never.customEqual("world")
			end)

			it("SHOULD fail as expected", function()
				local success = pcall(function()
					expect("hello").never.customEqual("hello")
				end)

				assert(success == false, "did not fail like expected")
			end)
		end)

		describe("WHEN chain within other matchers", function()
			it("SHOULD work as expected when the first to execute", function()
				expect("hello")
					.to.customEqual("hello")
					.to.equal("hello")
					.to.be.ok()
					.to.never.equal("foobar")
			end)

			it("SHOULD work as expected when the last to execute", function()
				expect("hello")
					.to.equal("hello")
					.to.be.ok()
					.to.never.equal("foobar")
					.to.customEqual("hello")
			end)
		end)
	end)
end
