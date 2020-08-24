--[[
	This test runner is invoked in all the environments that we want to test our
	project in.

	TestEZ's CLI targets Lemur, Roblox Studio, and Roblox-CLI.

	Assumes TestEZ is put into ReplicatedStorage and that test roots have a
	"TestEZTestRoot" CollectionService tag attached to them.
]]

-- luacheck: globals game script __LEMUR__

local TEST_CONTAINER_TAG = "TestEZTestRoot"

local hasCollectionService, CollectionService = pcall(game.GetService, game, "CollectionService")

-- ProcessService only exists when running under Roblox-CLI.
local isRobloxCli, ProcessService = pcall(game.GetService, game, "ProcessService")

local platform = {}

if __LEMUR__ then
	platform.exit = os.exit

	platform.error = function(message)
		print(message)
		platform.exit(1)
	end
elseif isRobloxCli then
	platform.exit = function(statusCode)
		ProcessService:ExitAsync(statusCode)
	end

	platform.error = function(message)
		print(message)
		platform.exit(1)
	end
else
	platform.exit = function() end

	platform.error = function(message)
		error(message, 0)
	end
end

local completed, suitePassed = xpcall(function()
	local TestEZ = require(script.TestEZ)

	local testContainers
	if hasCollectionService then
		testContainers = CollectionService:GetTagged(TEST_CONTAINER_TAG)
	else
		testContainers = _G.TESTEZ_TEST_CONTAINERS
	end

	if #testContainers == 0 then
		print(string.format(
			"No tests found. Did you give them the CollectionService tag %q?",
			TEST_CONTAINER_TAG
		))

		return true
	end

	local testResults = TestEZ.TestBootstrap:run(
		testContainers,
		TestEZ.Reporters.TextReporter
	)

	return testResults.failureCount == 0
end, debug.traceback)

if completed then
	if suitePassed then
		platform.exit(0)
	else
		platform.exit(1)
	end
else
	platform.error(suitePassed)
end