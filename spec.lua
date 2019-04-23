local LOAD_MODULES = {
	{"lib", "TestEZ"},
}

-- This makes sure we can load Lemur and other libraries that depend on init.lua
package.path = package.path .. ";?/init.lua"

-- If this fails, make sure you've cloned all Git submodules.
local lemur = require("modules.lemur")
local lfs = assert(require("lfs"), "LuaFileSystem is not installed, try `luarocks install luafilesystem`")

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
		if child.Name:match("%.spec$") then
			table.insert(foundTests, child)
		end

		findUnitTests(child, foundTests)
	end

	return foundTests
end

local MockOutput = {}
function MockOutput:__call(append)
	self.output = self.output .. append
end

local function runIntegrationTests()
	local TestEZ = habitat:require(root.TestEZ)
	local tests = {}

	for testName in lfs.dir("tests/") do
		if testName ~= "." and testName ~= ".." then
			local baseDirectory = "tests/" .. testName .. "/"
			local source = habitat:loadFromFs(baseDirectory .. testName .. ".spec.lua")
			local expectedOutput = assert(io.open(baseDirectory .. "output.txt")):read("*all")

			table.insert(tests, {
				path = { testName },
				method = function()
					describe(testName, function()
						it("should return the expected output", function()
							local testOutput = setmetatable({
								output = ""
							}, MockOutput)

							local unitPlan = TestEZ.TestPlanner.createPlan({
								method = habitat:require(source),
								path = { testName },
							})
							local results = TestEZ.TestRunner.runPlan(unitPlan)
							TestEZ.Reporters.TextReporter.report(results, testOutput)

							if testOutput.output ~= expectedOutput then
								io.open(baseDirectory .. "output.failure.txt", "w"):write(testOutput.output)
							end

							expect(testOutput.output).to.equal(expectedOutput)
						end)
					end)
				end,
			})
		end
	end

	local plan = TestEZ.TestPlanner.createPlan(tests)
	local results = TestEZ.TestRunner.runPlan(plan)
	TestEZ.Reporters.TextReporter.report(results)
end

-- Run all unit tests, which are located in .spec.lua files next to the source
local unitTests = findUnitTests(root.TestEZ)
print(("Running %d unit tests..."):format(#unitTests))

-- Unit tests are expected to load individual files relative to themselves
for _, test in ipairs(unitTests) do
	habitat:require(test)()
end

print("Running integration tests...")
runIntegrationTests()

print("All tests passed.")