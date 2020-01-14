local TestEZ = require(script.Parent.Parent.TestEZ)

return {
	function()
		assert(typeof(TestEZ) == "table")
		assert(typeof(TestEZ.run) == "function")
	end,
}