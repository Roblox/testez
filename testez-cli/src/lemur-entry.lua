-- This module has variables preprended to it by the TestEZ CLI that inform it
-- what modules need to be loaded.

-- luacheck: globals RUNNER_PATH TESTEZ_PATH SRC_PATH DEPS

assert(type(RUNNER_PATH) == "string")
assert(type(TESTEZ_PATH) == "string")
assert(type(SRC_PATH) == "string")
assert(type(DEPS) == "table" or DEPS == nil)

local lemur = require("lemur")

local habitat = lemur.Habitat.new()

local ReplicatedStorage = habitat.game:GetService("ReplicatedStorage")

local testRunner = habitat:loadFromFs(RUNNER_PATH)
testRunner.Name = "TestRunner"
testRunner.Parent = ReplicatedStorage

local testez = habitat:loadFromFs(TESTEZ_PATH)
testez.Name = "TestEZ"
testez.Parent = testRunner

local source = habitat:loadFromFs(SRC_PATH)
-- TODO: Library name?
source.Parent = ReplicatedStorage

_G.TESTEZ_TEST_CONTAINERS = { source }

if DEPS ~= nil then
	if DEPS.kind == "rotriever" then
		local packages = habitat:loadFromFs(DEPS.packagesPath)

		for _, dir in ipairs(packages:GetChildren()) do
			dir.Parent = ReplicatedStorage
		end
	elseif DEPS.kind == "git-submodules" then
		for _, dep in ipairs(DEPS.modules) do
			local container = habitat:loadFromFs(dep[1])
			container.Name = dep[2]
			container.Parent = ReplicatedStorage
		end
	else
		error(string.format("Unsupported dependency list kind %q", tostring(DEPS.kind)))
	end
end

habitat:require(testRunner)