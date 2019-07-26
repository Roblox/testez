return function(TestEZ)
    local Expectation = TestEZ.Expectation

    local ARBITRARY_NUMBER = 5
    local DIFFERENT_ARBITRARY_NUMBER = ARBITRARY_NUMBER + 1

    -- Works with primitives
    do
        local value1 = ARBITRARY_NUMBER
        local value2 = ARBITRARY_NUMBER
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = "teststring"
        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))
    end

    -- Works with list-style tables
    do
        local value1 = {2, 3, 4}
        local value2 = {2, 3, 4}
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = {3, 4, 2}
        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))
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
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = {
            num = ARBITRARY_NUMBER,
            str = "differentstring",
        }

        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))
    end

    -- Works for multi-deep tables
    do
        local value1 = {
            num = ARBITRARY_NUMBER,
            innerTable= {
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
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = {
            num = ARBITRARY_NUMBER,
            innerTable = {
                differentKey = "value"
            },
        }

        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))
    end

    -- Works for multi-deep table where some "levels" of the table are lists and some are dictionaries
    do
        local value1 = {
            {
                str = "value",
                innerTable1 = {
                    innerKey1 = {
                        innerInnerTable = { 1, 2, 3 },
                        innerInnerKey = "innerInnerValue"
                    },
                    innerKey2 = {
                        innerInnerNum = 5,
                    },
                    innerNum = 1,
                }
            },
            {
                str = "value",
            },
        }
        local value2 = {
            {
                str = "value",
                innerTable1 = {
                    innerKey1 = {
                        innerInnerTable = { 1, 2, 3 },
                        innerInnerKey = "innerInnerValue"
                    },
                    innerKey2 = {
                        innerInnerNum = 5,
                    },
                    innerNum = 1,
                }
            },
            {
                str = "value",
            },
        }

        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = {
            {
                str = "value",
                innerTable1 = {
                    innerKey1 = {
                        innerInnerTable = { 1, 10000, 3 },
                        innerInnerKey = "innerInnerValue"
                    },
                    innerKey2 = {
                        innerInnerNum = 5,
                    },
                    innerNum = 1,
                }
            },
            {
                str = "value",
            },
        }

        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))
    end

    -- Works for tables that are different in multiple locations
    do
        local value1 = {
            {
                str = "value",
                innerTable1 = {
                    innerKey1 = {
                        innerInnerTable = { 1, 2, 3 },
                        innerInnerKey = "innerInnerValue"
                    },
                    innerKey2 = {
                        innerInnerNum = 5,
                    },
                    innerNum = 1,
                }
            },
            {
                str = "value",
            },
        }
        local value2 = {
            {
                str = "value",
                innerTable1 = {
                    innerKey1 = {
                        innerInnerTable = { 1, 2, 3 },
                        innerInnerKey = "differentInnerInnerValue"
                    },
                    innerKey2 = {
                        innerInnerNum = 5,
                    },
                    innerNum = 100000,
                }
            },
            {
                str = "value",
            },
        }

        local expectation = Expectation.new(value1)
        assert(not pcall(expectation.to.deepEqual, value2))
        assert(pcall(expectation.never.to.deepEqual, value2))
    end

    -- Works for mixed list/dictionary tables
    do
        local value1 = {2, 3, 4, key = "value"}
        local value2 = {2, 3, 4, ["key"] = "value"}
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.deepEqual, value2))

        local value3 = {2, 3, 4, ["wrongkey"] = "value"}
        assert(not pcall(expectation.to.deepEqual, value3))
        assert(pcall(expectation.never.to.deepEqual, value3))

        local value4 = {2, 3, 4, ["key"] = "wrongvalue"}
        assert(not pcall(expectation.to.deepEqual, value4))
        assert(pcall(expectation.never.to.deepEqual, value4))
    end

    -- Works when RHS has more keys
    do
        local value1 = {
            aKey = "val1",
            anotherKey = "val2",
        }
        local value2 = {
            aKey = "val1",
            anotherKey = "val2",
            aThirdKey = "val3",
        }
        local expectation = Expectation.new(value1)
        assert(not pcall(expectation.to.deepEqual, value2))
        assert(pcall(expectation.never.to.deepEqual, value2))
    end

    -- Takes into account metatables, if desired
    do
        local value1 = {
            strUsedForComparison = "same",
            num = ARBITRARY_NUMBER,
        }
        local value2 = {
            strUsedForComparison = "same",
            num = DIFFERENT_ARBITRARY_NUMBER,
        }
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.to.deepEqual, value2))
        assert(pcall(expectation1.never.to.deepEqual, value2))

        -- Compare based only on strUsedForComparison
        local mt = {
            __eq = function(lhs, rhs)
                return lhs.strUsedForComparison == rhs.strUsedForComparison
            end
        }
        setmetatable(value1, mt)
        setmetatable(value2, mt)
        local expectation2 = Expectation.new(value1)
        assert(pcall(expectation2.to.deepEqual, value2))

        assert(not pcall(expectation1.to.deepEqual, value2, true))
        assert(pcall(expectation1.never.to.deepEqual, value2, true))
    end

    -- A variety of weird edge cases
    do
        local value1 = {}
        local value2 = {}
        local expectation1 = Expectation.new(value1)
        assert(pcall(expectation1.to.deepEqual, value2))
    end
    do
        local value1 = {{{}}}
        local value2 = {{}}
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.to.deepEqual, value2))
        assert(pcall(expectation1.never.to.deepEqual, value2))
    end
    -- Shallow compare on keys
    do
        local value1 = {
            [{}] = {{}}
        }
        local value2 = {
            [{}] = {{}}
        }
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.to.deepEqual, value2))
        assert(pcall(expectation1.never.to.deepEqual, value2))
    end
    do
        local value1 = nil
        local value2 = nil
        local expectation1 = Expectation.new(value1)
        assert(pcall(expectation1.to.deepEqual, value2))
    end
    do
        local value1 = 2
        local value2 = "2"
        local expectation1 = Expectation.new(value1)
        assert(not pcall(expectation1.to.deepEqual, value2))
        assert(pcall(expectation1.never.to.deepEqual, value2))
    end

end

