-- luacheck: globals describe it itFOCUS
return function()
	itFOCUS("run this", function()
	end)

	it("not that", function()
		error("shouldn't happen")
	end)
end