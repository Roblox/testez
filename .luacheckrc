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
		table = {
			fields = {
				find = {},
				create = {},
				pack = {},
			},
		},
	},
}

stds.testez = {
	read_globals = {
		"it", "describe", "beforeAll", "beforeEach", "afterAll", "afterEach", "fail", "expect"
	},
}

std = "lua51+roblox"

ignore = {
	"212", -- Unused argument, which triggers on unused 'self' too
}

files["tests/lifecycleHooks.lua"] = {
	std = "+testez",
}

files["tests/e2e"] = {
	std = "+testez"
}
