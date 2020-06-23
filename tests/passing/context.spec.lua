-- luacheck: globals describe beforeAll beforeEach it expect afterEach afterAll

return function()
	describe("context is passed between lifecycle hooks and it blocks", function()
		beforeAll(function(context)
			context.a = 1
		end)

		beforeEach(function(context)
			context.b = 1
		end)

		it("before hooks should run", function(context)
			expect(context.a).to.equal(1)
			expect(context.b).to.equal(1)
		end)

		afterEach(function(context)
			expect(context.b).to.equal(1)
		end)

		afterAll(function(context)
			-- Failures in afterAll aren't reported.
			expect(context.a).to.equal(1)
		end)
	end)
end