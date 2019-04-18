--[[
	Constants used throughout the testing framework.
]]

local TestEnum = {}

TestEnum.TestStatus = {
	Success = "Success",
	Failure = "Failure",
	Skipped = "Skipped"
}

TestEnum.NodeType = {
	Try = "Try",
	Describe = "Describe",
	It = "It",
	Before = "Before",
	After = "After",
	BeforeEach = "BeforeEach",
	AfterEach = "AfterEach"
}

TestEnum.NodeModifier = {
	None = "None",
	Skip = "Skip",
	Focus = "Focus"
}

return TestEnum