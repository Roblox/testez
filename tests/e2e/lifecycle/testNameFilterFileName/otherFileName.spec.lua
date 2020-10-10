return function()
	it("SHOULD NEVER RUN", function()
		fail("This should never have run in this file. Check testNamePattern.")
	end)
end
