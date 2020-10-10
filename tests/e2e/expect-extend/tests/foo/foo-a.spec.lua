return function()
	describe("lower", function()
		beforeAll(function()
			expect.extend({
				bar = function()
					return {
						message = "custom failure message (not)",
						pass = true,
					}
				end
			})
		end)

		it("SHOULD run", function()
			print("foo-a")
			expect(0).foo(0)
			expect(0).bar(0)
		end)
	end)
end
