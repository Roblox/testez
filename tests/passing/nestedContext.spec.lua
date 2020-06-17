-- luacheck: globals describe beforeAll it expect

return function()
	describe("setting context here", function()
		beforeAll(function(context)
			context.a = 1
		end)

		describe("should apply here", function()
			beforeAll(function(context)
				context.b = context.a + 1
			end)

			it("should see a and b", function(context)
				expect(context.a).to.equal(1)
				expect(context.b).to.equal(2)
			end)
		end)

		it("should not see b here", function(context)
			expect(context.a).to.equal(1)
			expect(context.b).to.never.be.ok()
		end)
	end)
end