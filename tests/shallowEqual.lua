return function(TestEZ)
    local Expectation = TestEZ.Expectation

    local ARBITRARY_NUMBER = 5

    -- Works with primitives
    do
        local value1 = ARBITRARY_NUMBER
        local value2 = ARBITRARY_NUMBER
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.shallowEqual, value2))

        local value3 = "teststring"
        assert(pcall(expectation.never.to.shallowEqual, value3))
    end

    -- Works with list-style tables
    do
        local value1 = {2, 3, 4}
        local value2 = {2, 3, 4}
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.shallowEqual, value2))

        local value3 = {3, 4, 2}
        assert(pcall(expectation.never.to.shallowEqual, value3))
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
        assert(pcall(expectation.to.shallowEqual, value2))

        local value3 = {
            num = ARBITRARY_NUMBER,
            str = "differentstring",
        }

        assert(pcall(expectation.never.to.shallowEqual, value3))
    end

    -- Behaves as expected with respect to references
    do
        local reference = {
            someData = ARBITRARY_NUMBER
        }
        local referenceCopy = {
            someData = ARBITRARY_NUMBER
        }
        local value1 = {
            key = reference
        }
        local value2 = {
            key = reference
        }
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.shallowEqual, value2))

        local value3 = {
            key = referenceCopy
        }
        assert(pcall(expectation.never.to.shallowEqual, value3))
    end

     -- Handles self-reference case
     do
        local value1 = {
            irrelevantKey = ARBITRARY_NUMBER,
        }
        value1["key"] = value1
        local value2 = {
            irrelevantKey = ARBITRARY_NUMBER,
        }
        value2["key"] = value2
        local expectation = Expectation.new(value1)
        assert(pcall(expectation.to.shallowEqual, value2))

        local value3 = {}
        value3["key"] = value3

        assert(not pcall(expectation.to.shallowEqual, value3, true))
        assert(pcall(expectation.never.to.shallowEqual, value3, true))
    end

end

