TestEZ provides a convenient method to run tests in a single pass:

```lua
local TestEZ = require(<path to TestEZ>)

TestEZ.TestBootstrap:run({ MY_TESTS })
```

This will run all files post-fixed with *.spec.lua (in Rojo) that are children of `MY_TESTS`

For example, you might have

- Shared (mapped to ReplicatedStorage)
    - AnimalModule
        - cat.lua
        - cat.spec.lua
        - dog.lua
        - dog.spec.lua

then setting `MY_TESTS = game.ReplicatedStorage.Shared.AnimalModule` would run the tests in cat.spec.lua and dog.spec.lua