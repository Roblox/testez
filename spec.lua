-- There are no tests for TestEZ yet, oh no!

-- This makes sure we can load Lemur and other libraries that depend on init.lua
package.path = package.path .. ";?/init.lua"

-- If this fails, make sure you've run `lua bin/install-dependencies.lua` first!
require("modules.lemur")

os.exit(0)