local LOAD_MODULES = {
	{"lib", "TestEZ"},
	{"tests", "TestEZTests"},
}

-- This makes sure we can load Lemur and other libraries that depend on init.lua
package.path = package.path .. ";?/init.lua"

-- If this fails, make sure you've cloned all Git submodules.
local lemur = require("modules.lemur")

--[[
	Collapses ModuleScripts named 'init' into their parent folders.

	This is the same behavior as Rojo.
]]
local function collapse(root)
	local init = root:FindFirstChild("init")
	if init then
		init.Name = root.Name
		init.Parent = root.Parent

		for _, child in ipairs(root:GetChildren()) do
			child.Parent = init
		end

		root:Destroy()
		root = init
	end

	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("Folder") then
			collapse(child)
		end
	end

	return root
end

local habitat = lemur.Habitat.new()

local root = lemur.Instance.new("Folder")
root.Name = "Root"

for _, module in ipairs(LOAD_MODULES) do
	local container = habitat:loadFromFs(module[1])
	container.Name = module[2]
	container.Parent = root
end

root = collapse(root)

local function findUnitTests(container, foundTests)
	foundTests = foundTests or {}

	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("ModuleScript") then
			table.insert(foundTests, child)
		end

		findUnitTests(child, foundTests)
	end

	return foundTests
end

-- Run all unit tests, which are located in .spec.lua files next to the source
local unitTests = findUnitTests(root.TestEZTests)
print("Running unit tests...")
local failureCount = 0
local successCount = 0
local errorMessages = {}

-- Unit tests are expected to load individual files relative to themselves
for _, testModule in ipairs(unitTests) do
	local tests = habitat:require(testModule)

	for name, testFunction in pairs(tests) do
		local success, message = pcall(testFunction)

		if success then
			successCount = successCount + 1
		else
			failureCount = failureCount + 1
			table.insert(errorMessages, ("Test: %s\nError: %s"):format(name, message))
		end
	end
end

print(("Unit tests: %d passed, %d failed\n"):format(successCount, failureCount))
if failureCount > 0 then
	print(table.concat(errorMessages, "\n\n"))
	os.exit(1)
end

print("All tests passed.")