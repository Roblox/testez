return function()
	beforeAll(function()
		print("init.spec")
		expect.extend({
			foo = function()
				return {
					message = "custom failure message (not)",
					pass = true,
				}
			end
		})
	end)
end
