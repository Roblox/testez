--[[
	This test runner is invoked in all the environments that we want to test our
	library in.

	We target Lemur, Roblox Studio, and Roblox-CLI.
]]

-- luacheck: globals __LEMUR__

local isRobloxCli, ProcessService = pcall(game.GetService, game, "ProcessService")

local function findUnitTests(container, foundTests)
	foundTests = foundTests or {}

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("ModuleScript") then
			table.insert(foundTests, child)
		end
	end

	return foundTests
end

local completed, result = xpcall(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local testModules = findUnitTests(ReplicatedStorage.TestEZTests)

	local totalCount = 0
	local failureCount = 0
	local successCount = 0
	local errorMessages = {}

	for _, testModule in ipairs(testModules) do
		local tests = require(testModule)

		print(string.format("%s", testModule.Name))

		for testName, testFunction in pairs(tests) do
			local success, message = pcall(testFunction)
			totalCount = totalCount + 1

			if success then
				print(string.format("  [PASS] %s", testName))
				successCount = successCount + 1
			else
				print(string.format("  [FAIL] %s", testName))
				failureCount = failureCount + 1

				local logMessage = string.format("Test: %s\nError: %s", testName, message)
				table.insert(errorMessages, logMessage)
			end
		end
	end

	print()
	print(string.format("%s tests run: %s passed, %s failed", totalCount, successCount, failureCount))

	if #errorMessages > 0 then
		print()
		print(table.concat(errorMessages, "\n\n"))
	end

	return failureCount == 0 and 0 or 1
end, debug.traceback)

local statusCode
local errorMessage = nil
if completed then
	statusCode = result
else
	statusCode = 1
	errorMessage = result
end

if __LEMUR__ then
	-- Lemur has access to normal Lua OS APIs

	if errorMessage ~= nil then
		print(errorMessage)
	end
	os.exit(statusCode)
elseif isRobloxCli then
	-- Roblox CLI has a special service to terminate the process

	if errorMessage ~= nil then
		print(errorMessage)
	end
	ProcessService:Exit(statusCode)
else
	-- In Studio, we can just throw an error to get the user's attention

	if errorMessage ~= nil then
		error(errorMessage, 0)
	end
end