# TestEZ Changelog

## Current master
* Added `Expectation.extend` which allow projects to add their own matchers to TestEZ.
  * Matchers are functions that should return an object with with two keys, boolean `pass` and a string `message`

```lua
-- setting up test runners
local TestEZ = require(ReplicatedStorage.Packages.Dev.TestEZ)

TestEZ.Expectation.extend({
	divisibleBy = function(receivedValue, expectedValue)
		local pass = receivedValue % expectedValue == 0
		if pass then
			return {
				pass = true,
				message = ("Expected %s not to be divisible by %s"):format(receivedValue, expectedValue)
			}
		else
			return {
				pass = false,
				message = ("Expected %s to be divisible by %s"):format(receivedValue, expectedValue)
			}
		end
	end
})

-- spec.lua
it("should be an even number", function()
	expect(10).to.be.divisibleBy(2)
end)
```

## 0.1.1 (2020-01-23)
* Added beforeAll, beforeEach, afterEach, afterAll lifecycle hooks for testing
	* The setup and teardown behavior of these hooks attempt to reach feature parity with [jest](https://jestjs.io/docs/en/setup-teardown).


## 0.1.0 (2019-11-01)
* Initial release.
