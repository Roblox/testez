-- luacheck: globals fdescribe it xit

return function()
	fdescribe("focussed", function()
		xit("should still skip", function()
			error("shouldn't happen")
		end)
	end)

	it("should not be in focus", function()
		error("also shouldn't happen")
	end)
end
