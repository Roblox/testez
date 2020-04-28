local TestEZ = script.Parent.Parent.TestEZ
local Expectation = require(TestEZ.Expectation)

return {
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
    ["it should succeed if types match"] = function()
        local expectNumber = Expectation.new(5)
        local expectString = Expectation.new("Foo")
        local expectFunction = Expectation.new(function()
            return true
        end)

        local success = pcall(function()
            expectNumber:a("number")
            expectString:a("string")
            expectFunction:a("function")
        end)

        assert(success, "should succeed")
    end,
    ["it should fail if types don't match"] = function()
        local expectNumber = Expectation.new(5)

        local success, message = pcall(function()
            expectNumber:a("string")
        end)

        assert(not success, "should fail")
        assert(
            message:match('Expected value of type "string", got value "5" of type number'),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["nil should be not ok"] = function()
        local expect = Expectation.new(nil)

        local successNever = pcall(function()
            expect.never:ok()
        end)

        assert(successNever, "should succeed")

        local successOk, message = pcall(function()
            expect:ok()
        end)

        assert(not successOk, "should fail")
        assert(
            message:match('Expected value "nil" to be non%-nil'),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["false should be ok"] = function()
        local expect = Expectation.new(false)

        local successOk = pcall(function()
            expect:ok()
        end)

        assert(successOk, "should succeed")

        local successNever, message = pcall(function()
            expect.never:ok()
        end)

        assert(not successNever, "should fail")
        assert(
            message:match('Expected value "false" to be nil'),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["equal values should be equal"] = function()
        local expect = Expectation.new("foo")

        local success = pcall(function()
            expect:equal("foo")
        end)

        assert(success, "should succeed")
    end,
    ["different values should not be equal"] = function()
        local expect = Expectation.new("5")

        local success, message = pcall(function()
            expect:equal(5)
        end)

        assert(not success, "should fail")
        assert(
            message:match('Expected value "5" %(number%), got "5" %(string%) instead'),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["similar numbers should be near"] = function()
        local expect = Expectation.new(0.1111111)

        local success = pcall(function()
            expect:near(1.0 / 9.0)
        end)

        assert(success, "should succeed")
    end,
    ["numbers outside the default limit should not be near"] = function()
        local expect = Expectation.new(0.11111)

        local success, message = pcall(function()
            expect:near(1.0 / 9.0)
        end)

        assert(not success, "should fail")
        assert(
            message:match("Expected value to be near %d+.%d+ %(within %d+.%d+%) but got %d+.%d+ instead"),
            ("Error message does not match:\n%s\n"):format(message)
        )
    end,
    ["near should respect limit argument"] = function()
        local expect = Expectation.new(0.1)

        local success = pcall(function()
            expect:near(1.0 / 9.0, 0.1)
        end)

        assert(success, "should succeed")
    end,
}