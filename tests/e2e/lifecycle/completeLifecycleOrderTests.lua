-- Shared test cases asserting lifecycle hooks are firing in the correct order

return function()
	describe("full example", function()
		beforeAll(function(context)
			context.globalState = {}

			table.insert(context.globalState, "beforeAll")
			expect(table.find(context.globalState, "beforeAll")).to.equal(1)
		end)

		beforeEach(function(context)
			table.insert(context.globalState, "beforeEach")
			expect(table.find(context.globalState, "beforeEach")).to.equal(2)
		end)

		it("it block", function(context)
			table.insert(context.globalState, "test")
			expect(table.find(context.globalState, "test")).to.equal(3)
		end)

		afterEach(function(context)
			table.insert(context.globalState, "afterEach")
			expect(table.find(context.globalState, "afterEach")).to.equal(4)
		end)

		afterAll(function(context)
			table.insert(context.globalState, "afterAll")
			expect(table.find(context.globalState, "afterAll")).to.equal(5)
		end)
	end)

	describe("no it block - should not call beforeEach or afterEach", function()
		beforeAll(function(context)
			context.globalState = {}

			table.insert(context.globalState, "beforeAll")
			expect(table.find(context.globalState, "beforeAll")).to.equal(1)
		end)

		beforeEach(function()
			fail("should not be called")
		end)

		afterEach(function()
			fail("should not be called")
		end)

		afterAll(function(context)
			table.insert(context.globalState, "afterAll")
			expect(table.find(context.globalState, "afterAll")).to.equal(2)
		end)
	end)
end
