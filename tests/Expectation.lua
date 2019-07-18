return function(TestEZ)
    local Expectation = TestEZ.Expectation

    local ARBITRARY_NUMBER = 5

    -- Works with primitives
    do
        local value1 = ARBITRARY_NUMBER
        local value2 = ARBITRARY_NUMBER
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.deepEqual, value2))

        local value3 = "teststring"
        assert(not pcall(expectation.deepEqual, value3))
    end

    -- Works with singly-deep tables
    do
        local value1 = {
            num = ARBITRARY_NUMBER,
            str = "teststring",
        }
        local value2 = {
            num = ARBITRARY_NUMBER,
            str = "teststring",
        }
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.deepEqual, value2))

        local value3 = {
            num = ARBITRARY_NUMBER,
            str = "differentstring",
        }

        assert(not pcall(expectation.deepEqual, value3))
    end

    -- Works for multi-deep tables
    do
        local value1 = {
            num = ARBITRARY_NUMBER,
            innerTable1= {
                key = "value"
            },
        }
        local value2 = {
            num = ARBITRARY_NUMBER,
            innerTable = {
                key = "value"
            },
        }
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.deepEqual, value2))

        local value3 = {
            num = ARBITRARY_NUMBER,
            innerTable = {
                differentKey = "value"
            },
        }

        assert(not pcall(expectation.deepEqual, value3))
    end

    -- Works for tables as keys
    do
        local tableKey1 = {
            key = "value"
        }
        local tableKey2 = {
            key = "value"
        }
        local value1 = {
            [tableKey1] = ARBITRARY_NUMBER,
        }
        local value2 = {
            [tableKey2] = ARBITRARY_NUMBER,
        }
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.deepEqual, value2))

        local tableKey3 = {
            key = "differentvalue",
        }
        local value3 = {
            [tableKey3] = ARBITRARY_NUMBER,
        }

        assert(not pcall(expectation.deepEqual, value3))
    end

    -- Takes into account metatables, if desired
    do
        local value1 = {
            strUsedForComparison = "same",
            num = ARBITRARY_NUMBER,
        }
        local value2 = {
            strUsedForComparison = "same",
            num = ARBITRARY_NUMBER,
        }
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.deepEqual, value2))

        local mt = {
            __eq = function(lhs, rhs)
                return lhs.strUsedForComparison == rhs.strUsedForComparison
            end
        }
        setmetatable(value1, mt)
        setmetatable(value2, mt)
        local expectation2 = Expectation.new(value1)
        assert(pcall(expectation2.deepEqual, value2))
        assert(not pcall(expectation1.deepEqual, value2, true))
    end

    -- Takes into account maximum recursive depth
    do
        local value1 = {
            inner1 = {
                inner2 = {
                    inner3 = {
                        inner4 = {
                            inner5 = {
                                key = "value"
                            }
                        }
                    }
                }
            }
        }
        local value2 = {
            inner1 = {
                inner2 = {
                    inner3 = {
                        inner4 = {
                            inner5 = {
                                key = "value"
                            }
                        }
                    }
                }
            }
        }
        -- value1 and value2 are deeply equal, but are not shallowly equal at a depth of 3...
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.deepEqual, value2, false, 3))
        -- ... but are equal at a depth of 10
        assert(pcall(expectation1.deepEqual, value2, false, 10))
    end
end

