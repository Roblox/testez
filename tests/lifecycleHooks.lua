return function(TestEZ)

	local beforeXCalls = 0
	local afterXCalls = 0

	local beforeYCalls = 0
	local beforeZCalls = 0

	local beforeEachCalls = 0
	local afterEachCalls = 0

	local plan = TestEZ.TestPlanner.createPlan({
		{
		method = function()
			before(function()
				print("run before")
				beforeXCalls = beforeXCalls + 1
			end)

			after(function()
				print("run after")
				afterXCalls = afterXCalls + 1
			end)

			beforeEach(function()
				print("run beforeEach")
				beforeEachCalls = beforeEachCalls + 1
			end)

			afterEach(function()
				print("run afterEach")
				afterEachCalls = afterEachCalls + 1
			end)

			it("runs", function()
				print("run it")
			end)

			describe('myTests', function()

				before(function()
					print("run beforeZ")
					beforeZCalls = beforeZCalls + 1
				end)

				it("runs", function()
					print("run it")
				end)

				describe('no tests', function()
					before(function()
						beforeYCalls = beforeYCalls + 1
					end)
				end)
			end)
		end,
		path = {'lifecycleHooksTest'}
	}
	})

	local results = TestEZ.TestRunner.runPlan(plan)

	assert(beforeXCalls == 1)
	assert(afterXCalls == 1)

	assert(beforeYCalls == 0)
	assert(beforeZCalls == 1)

	assert(beforeEachCalls == 2)
	assert(afterEachCalls == 2)
	print(results:visualize())

	assert(results.failureCount == 0)
end