local TestEZ = script.Parent.Parent.TestEZ
local Expectation = require(TestEZ.Expectation)

return {
    ["it should fail if expect is given more than one argument"] = function()
        local success = pcall(function()
            Expectation.new(true, true)
        end)

        assert(not success, "should fail")
    end,
    ["it should succeed if an empty function is expected to never throw"] = function()
        local function shouldNotThrow()
        end

        local expect = Expectation.new(shouldNotThrow)

        local success = pcall(function()
            expect.never:throw()
        end)

        assert(success, "should succeed")
    end,
    ["it should succeed if a throwing function is expected to throw"] = function()
        local function shouldThrow()
            error("oof")
        end

        local expect = Expectation.new(shouldThrow)

        local success = pcall(function()
            expect:throw()
        end)

        assert(success, "should succeed")
    end,
    ["it should fail if a throwing function is expected to never throw"] = function()
        local function shouldThrow()
            error("oof")
        end

        local expect = Expectation.new(shouldThrow)

        local success, message = pcall(function()
            expect.never:throw()
        end)

        assert(not success, "should fail")
        assert(
            message:match("Expected function to succeed, but it threw an error:"),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["it should fail if an empty function is expected to throw"] = function()
        local function shouldNotThrow()
        end

        local expect = Expectation.new(shouldNotThrow)

        local success, message = pcall(function()
            expect:throw()
        end)

        assert(not success, "should fail")
        assert(
            message:match("Expected function to throw an error, but it did not."),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
}