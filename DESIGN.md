# TestEZ Design Notes

## Test Flow
Testing using this module is broken down into four steps:

1. Load tests
2. Create test plan
3. Execute test plan
4. Report results

Before executing the test plan, we can also modify it to change semantics separately from the code.

### #1: Load tests
All ModuleScript objects that have a name ending in `.spec` are loaded as tests. On the filesystem, they appear as `.spec.lua` files.

These tests should return a function that describes the actual test using the `describe`, `it`, and `expect` functions. These functions are automatically injected into the test environment when available.

A test suite for addition might look like this:

```lua
return function()
	describe("Addition", function()
		it("should be commutative", function()
			local a, b, c = 5, 8, 11
			expect(a + b + c).to.equal(c + b + a)
		end)

		it("should be associative", function()
			local a, b, c = 7, 4, 9
			expect((a + b) + c).to.equal(a + (b + c))
		end)
	end)
end
```

All test assertions should be contained inside the `it` blocks.

### #2: Create test plan
A tree of tests is constructed out of all the `describe` and `it` calls in the tree. No test code is actually run.

This allows us to potentially output a tree of the tests in the system without actually running them. It also gives us a mechanism to run only specific tests.

This step is carried out by `TestPlanner`. It uses `TestPlanBuilder` to hold temporary state relevant only when building the plan, and then returns a `TestPlan` object.

To debug the test plan tree, use `plan:visualize()`

### #3: Execute test plan
A tree of test results is created that mirrors the test plan nodes.

This step is carried out by `TestRunner`. It creates a `TestSession` using the `TestPlan` from the previous step. This object holds state only relevant when building the test results, then returns a `TestResults` object.

To debug the result tree, use `results:visualize()`

### #4: Report results
Reporting is handled by a test reporter object, which is just a table with a `report` method on it. It takes a `TestResults` object and outputs it to standard output, creates a GUI, or tells TestService about the results.

This is pluggable, and could conceivably output in any format.

## System Architecture
The system is broken down in a way that eliminates global state, provides multiple abstraction layers for each operation, and stores plain data in a way that's agnostic to the operations performed upon it.

In both the planning and running phases of tests, a stateless module (`TestPlanner` and `TestRunner`) creates a temporary object to hold state about the operation it's trying to perform. These objects (`TestPlanBuilder` and `TestSession`) allow the code to traverse and build trees without passing around extra state between iterations.

When the modules are done using these builder objects, they call `finalize` on them to receive a `TestPlan` or `TestResults` object. These objects are passed back to the original caller.

`TestBootStrap` packages up use of the stages of testing into a simpler interface that also automatically locates test modules. When more advanced functionality is desired, it's easy to stop using TestBootstrap and instead call the underlying objects directly.