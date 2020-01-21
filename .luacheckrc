stds.roblox = {
	globals = {
		"game"
	},
	read_globals = {
		-- Roblox globals
		"script",

		-- -- Extra functions
		"typeof",
		"tick", "warn",
	}
}

stds.testez = {
	read_globals = {
		"it", "describe", "beforeAll", "beforeEach", "afterAll", "afterEach",
	},
}

std = "lua51+roblox"

ignore = {
	"212", -- Unused argument, which triggers on unused 'self' too
}

files["tests/lifecycleHooks.lua"] = {
	std = "+testez",
}