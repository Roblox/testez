local TestEZ = require(script.Parent.Parent.TestEZ)

local lifecycleOrder = {}
local function insertLifecycleEvent(lifecycleString)
	table.insert(lifecycleOrder, lifecycleString)
end

local function lifecycleOrderMatches(array)
	-- shallow equals between lifecycleOrder and passed array
	for index, value in ipairs(lifecycleOrder) do
		if array[index] ~= value then
			return false
		end
	end

	for index, value in ipairs(array) do
		if lifecycleOrder[index] ~= value then
			return false
		end
	end

	return true
end

local function arrayToString(array)
	return table.concat(array, "\n\t")
end

local function expectLifecycleOrder(array)
	assert(
		lifecycleOrderMatches(array),
		string.format("lifecycle order did not match expected order.\nGot: {\n\t%s\n}", arrayToString(lifecycleOrder))
	)
end

return {
	["should run lifecycle methods in single-level"] = function()
		lifecycleOrder = {}

		local plan = TestEZ.TestPlanner.createPlan({
			{
			method = function()
				beforeAll(function()
					insertLifecycleEvent("1 - beforeAll")
				end)

				afterAll(function()
					insertLifecycleEvent("1 - afterAll")
				end)

				beforeEach(function()
					insertLifecycleEvent("1 - beforeEach")
				end)

				afterEach(function()
					insertLifecycleEvent("1 - afterEach")
				end)

				it("runs root", function()
					insertLifecycleEvent("1 - test")
				end)
			end,
			path = {'lifecycleHooksTest'}
		}
		})

		local results = TestEZ.TestRunner.runPlan(plan)

		expectLifecycleOrder({
			"1 - beforeAll",
			"1 - beforeEach",
			"1 - test",
			"1 - afterEach",
			"1 - afterAll",
		})

		assert(results.failureCount == 0)
	end,
	["should run lifecycle methods in order in nested trees"] = function()
		lifecycleOrder = {}
		local plan = TestEZ.TestPlanner.createPlan({
			{
			method = function()
				beforeAll(function()
					insertLifecycleEvent("1 - beforeAll")
				end)

				afterAll(function()
					insertLifecycleEvent("1 - afterAll")
				end)

				beforeEach(function()
					insertLifecycleEvent("1 - beforeEach")
				end)

				afterEach(function()
					insertLifecycleEvent("1 - afterEach")
				end)

				it("runs root", function()
					insertLifecycleEvent("1 - test")
				end)

				describe("nestedDescribe", function()
					beforeAll(function()
						insertLifecycleEvent("2 - beforeAll")
					end)

					afterAll(function()
						insertLifecycleEvent("2 - afterAll")
					end)

					beforeEach(function()
						insertLifecycleEvent("2 - beforeEach")
					end)

					afterEach(function()
						insertLifecycleEvent("2 - afterEach")
					end)

					it("runs", function()
						insertLifecycleEvent("2 - test")
					end)

					describe("no tests", function()
						before(function()
							insertLifecycleEvent("3 - beforeAll")
						end)
					end)
				end)
			end,
			path = {'lifecycleHooksTest'}
		}
		})

		local results = TestEZ.TestRunner.runPlan(plan)

		expectLifecycleOrder({
			"1 - beforeAll",
			"1 - beforeEach",
			"1 - test",
			"1 - afterEach",
			"2 - beforeAll",
			"1 - beforeEach",
			"2 - beforeEach",
			"2 - test",
			"2 - afterEach",
			"1 - afterEach",
			"2 - afterAll",
			"1 - afterAll",
		})

		assert(results.failureCount == 0)
	end,
	["beforeAll should only run once per describe block"] = function()
		lifecycleOrder = {}
		local plan = TestEZ.TestPlanner.createPlan({
			{
			method = function()
				beforeAll(function()
					insertLifecycleEvent("1 - beforeAll")
				end)

				it("runs 1", function()
					insertLifecycleEvent("1 - test")
				end)

				describe("nestedDescribe", function()
					beforeAll(function()
						insertLifecycleEvent("2 - beforeAll")
					end)

					it("runs 2", function()
						insertLifecycleEvent("2 - test")
					end)

					it("runs 2 again", function()
						insertLifecycleEvent("2 - test again")
					end)
				end)
			end,
			path = {'lifecycleHooksTest'}
		}
		})

		local results = TestEZ.TestRunner.runPlan(plan)

		expectLifecycleOrder({
			"1 - beforeAll",
			"1 - test",
			"2 - beforeAll",
			"2 - test",
			"2 - test again",
		})

		assert(results.failureCount == 0)
	end,
}
