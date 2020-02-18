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
    ["it should allow for custom expectations using extend"] = function()
        Expectation.extend({
            foo = function(received, expected)
                local pass = received == expected
                if pass then
                    return {
                        message = string.format("custom failure message (not)"),
                        pass = true,
                    }
                else
                    return {
                        message = string.format("custom failure message"),
                        pass = false,
                    }
                end
            end,
        })

        do
            -- foo match (normal)
            local success = pcall(function()
                local expect = Expectation.new(100)
                return expect:foo(100)
            end)

            assert(success == true, "foo should not fail if the values are the same")
        end

        do
            -- foo mis-match (normal)
            local success, value = pcall(function()
                local expect = Expectation.new(100)
                return expect:foo(200)
            end)

            assert(success == false, "foo should fail if the values are not the same")
            assert(value == "custom failure message", "should allow for custom failure message")
        end

        do
            -- foo match (never)
            local success, value = pcall(function()
                local expect = Expectation.new(100)
                return expect.never:foo(100)
            end)

            assert(success == false, "should fail if matching and inverse with never")
            assert(value == "custom failure message (not)", "should allow for custom failure message (not)")
        end

        do
            -- foo mis-match (never)
            local success = pcall(function()
                local expect = Expectation.new(100)
                return expect.never:foo(200)
            end)

            assert(success == true, "should not fail if mis-matching and inverse with never")
        end

        do
            -- both
            local success = pcall(function()
                local expect = Expectation.new(100)
                return expect
                    .never:foo(200)
                    :foo(100)
            end)

            assert(success == true, "should use the last expectation")
        end
    end,
}