stds.roblox = {
	read_globals = {
		game = {
			other_fields = true,
		},
		table = {
			other_fields = true,
		},

		-- Roblox globals
		"script",

		-- Extra functions
		"tick", "warn", "spawn", "delay",
		"wait", "settings", "UserSettings", "typeof",

		-- Types
		"Vector2", "Vector3",
		"Color3",
		"UDim", "UDim2",
		"Ray",
		"Rect",
		"CFrame",
		"Enum",
		"Instance",
		"TweenInfo",
		"Random",
		"NumberRange",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"ColorSequence",
		"BrickColor",
	}
}

stds.tests = {
	read_globals = {
		-- TestEz
		"describe",
		"it", "itFOCUS", "itSKIP",
		"FOCUS", "SKIP", "HACK_NO_XPCALL",
		"expect", "fail",

		"beforeEach", "afterEach", "beforeAll", "afterAll",
	}
}

std = "lua51+roblox+tests"
