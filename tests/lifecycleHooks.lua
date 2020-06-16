local TestEZ = require(script.Parent.Parent.TestEZ)

local function expectShallowEquals(array1, array2)
	local function shallowEquals()
		for index, value in ipairs(array1) do
			if array2[index] ~= value then
				return false
			end
		end

		for index, value in ipairs(array2) do
			if array1[index] ~= value then
				return false
			end
		end

		return true
	end

	if not shallowEquals() then
		error(string.format(
			"Expected: {\n\t%s\n}.\nGot: {\n\t%s\n}",
			table.concat(array2, "\n\t"),
			table.concat(array1, "\n\t")
		))
	end
end

local function expectNoFailures(results)
	assert(results.failureCount == 0, "Some lifecycleHook test failed!")
end

local function runTestPlan(testPlan)
	local lifecycleOrder = {}
	local function insertLifecycleEvent(lifecycleString)
		table.insert(lifecycleOrder, lifecycleString)
	end

	local plan = TestEZ.TestPlanner.createPlan({
		{
			method = function()
				-- This function environment hack is needed because the testPlan
				-- function is not defined or required from within a test. This
				-- shouldn't come up in real tests.
				setfenv(testPlan, getfenv())
				testPlan(insertLifecycleEvent)
			end,
			path = {'lifecycleHooksTest'}
		}
	})

	local results = TestEZ.TestRunner.runPlan(plan)
	return results, lifecycleOrder
end

return {
	["should run lifecycle methods in single-level"] = function()
		local results, lifecycleOrder = runTestPlan(function(insertLifecycleEvent)
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

			it("runs root again", function()
				insertLifecycleEvent("1 - another test")
			end)
		end)

		expectShallowEquals(lifecycleOrder, {
			"1 - beforeAll",
			"1 - beforeEach",
			"1 - test",
			"1 - afterEach",
			"1 - beforeEach",
			"1 - another test",
			"1 - afterEach",
			"1 - afterAll",
		})

		expectNoFailures(results)
	end,
	["should run lifecycle methods in order in nested trees"] = function()
		-- follows spec from jest https://jestjs.io/docs/en/setup-teardown#scoping
		local results, lifecycleOrder = runTestPlan(function(insertLifecycleEvent)
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
					beforeAll(function()
						insertLifecycleEvent("3 - beforeAll")
					end)

					afterAll(function()
						insertLifecycleEvent("3 - afterAll")
					end)
				end)
			end)

			it("runs root again", function()
				insertLifecycleEvent("1 - another test")
			end)
		end)

		expectShallowEquals(lifecycleOrder, {
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
			"3 - beforeAll",
			"3 - afterAll",
			"2 - afterAll",
			"1 - beforeEach",
			"1 - another test",
			"1 - afterEach",
			"1 - afterAll",
		})
		expectNoFailures(results)
	end,
	["beforeAll should only run once per describe block"] = function()
		local results, lifecycleOrder = runTestPlan(function(insertLifecycleEvent)
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
		end)

		expectShallowEquals(lifecycleOrder, {
			"1 - beforeAll",
			"1 - test",
			"2 - beforeAll",
			"2 - test",
			"2 - test again",
		})
		expectNoFailures(results)
	end,
	["lifecycle failures should fail test node"] = function()
		local function failLifecycleCase(hookType)
			local itWasRun = false
			local results = runTestPlan(function(insertLifecycleEvent)

				if hookType == "beforeAll" then
					beforeAll(function()
						error("this is an error")
					end)
				end

				if hookType == "beforeEach" then
					beforeEach(function()
						error("this is an error")
					end)
				end

				if hookType == "afterEach" then
					afterEach(function()
						error("this is an error")
					end)
				end

				if hookType == "afterAll" then
					afterAll(function()
						error("this is an error")
					end)
				end

				it("runs root", function()
					itWasRun = true
				end)
			end)

			assert(results.failureCount == 1, string.format("Expected %s failure to fail test run", hookType))

			if hookType:find("before") then
				-- if before* hooks fail, our test node should not run
				assert(itWasRun == false, "it node was ran despite failure on run: " .. hookType)
			end
		end

		failLifecycleCase("beforeAll")
		failLifecycleCase("beforeEach")
		failLifecycleCase("afterEach")
		failLifecycleCase("afterAll")
	end,
}