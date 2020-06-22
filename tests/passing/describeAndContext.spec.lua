-- luacheck: globals describe expect

return function()
	describe("this shouldn't be able to access context", function(context)
		expect(context).to.never.be.ok()
	end)
end
