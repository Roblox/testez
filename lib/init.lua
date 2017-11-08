local TestEZ = {
	Expectation = require(script.Expectation),
	TestBootstrap = require(script.TestBootstrap),
	TestEnum = require(script.TestEnum),
	TestPlan = require(script.TestPlan),
	TestPlanBuilder = require(script.TestPlanBuilder),
	TestPlanner = require(script.TestPlanner),
	TestResults = require(script.TestResults),
	TestRunner = require(script.TestRunner),
	TestSession = require(script.TestSession),

	Reporters = {
		TextReporter = require(script.Reporters.TextReporter),
	},
}

return TestEZ