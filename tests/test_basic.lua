#!/usr/bin/env lua5.4

-- Basic test for ComputoLua binding
-- Test the core functionality: computo.execute({"+", 3, 5}) should return 8

-- Set up the module path to find our compiled module
-- Add the build directory to package.cpath
package.cpath = package.cpath .. ";./build/?.so;../build/?.so"

-- Try to load the module
local computo = require("computo_lua")

-- Helper function for test assertions
local function test_assert(condition, message)
    if not condition then
        error("Test failed: " .. (message or "assertion failed"))
    end
    print("✓ " .. (message or "test passed"))
end

-- Test 1: Basic addition
print("Testing basic addition: {'+', 3, 5}")
local result = computo.execute({"+", 3, 5})
test_assert(result == 8, "Addition: {'+', 3, 5} should return 8, got " .. tostring(result))

-- Test 2: Basic subtraction
print("Testing basic subtraction: {'-', 10, 3}")
local result2 = computo.execute({"-", 10, 3})
test_assert(result2 == 7, "Subtraction: {'-', 10, 3} should return 7, got " .. tostring(result2))

-- Test 3: Basic multiplication
print("Testing basic multiplication: {'*', 4, 6}")
local result3 = computo.execute({"*", 4, 6})
test_assert(result3 == 24, "Multiplication: {'*', 4, 6} should return 24, got " .. tostring(result3))

-- Test 4: Basic division
print("Testing basic division: {'/', 15, 3}")
local result4 = computo.execute({"/", 15, 3})
test_assert(result4 == 5, "Division: {'/', 15, 3} should return 5, got " .. tostring(result4))

-- Test 5: Nested operations
print("Testing nested operations: {'*', {'+', 2, 3}, 4}")
local result5 = computo.execute({"*", {"+", 2, 3}, 4})
test_assert(result5 == 20, "Nested: {'*', {'+', 2, 3}, 4} should return 20, got " .. tostring(result5))

-- Test 6: Multiple operands
print("Testing multiple operands: {'+', 1, 2, 3, 4}")
local result6 = computo.execute({"+", 1, 2, 3, 4})
test_assert(result6 == 10, "Multiple operands: {'+', 1, 2, 3, 4} should return 10, got " .. tostring(result6))

-- Test 7: Error handling - invalid operator
print("Testing error handling with invalid operator")
local success, err = pcall(function()
    return computo.execute({"invalid_op", 1, 2})
end)
test_assert(not success, "Invalid operator should raise an error")
test_assert(string.find(err, "Computo execution error"), "Error should mention 'Computo execution error'")
print("✓ Error handling works correctly")

print("\nAll tests passed! ✓")
print("ComputoLua basic functionality is working correctly.")