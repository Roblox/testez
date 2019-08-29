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

std = "lua51+roblox"

ignore = {
	"212", -- Unused argument, which triggers on unused 'self' too
}