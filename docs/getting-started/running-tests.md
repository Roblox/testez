TestEZ provides a convenient method to run tests in a single pass:

```lua
local TestEZ = require(<path to TestEZ>)

TestEZ.TestBootstrap:run({ MY_TESTS })
```

The method also returns information about the test run that can be used to take further action!

The internals of TestEZ are being reworked, so accessing other APIs at this time isn't recommended.