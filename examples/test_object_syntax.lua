#!/usr/bin/env lua5.4

-- Quick test for object syntax support

-- Set up module path
package.cpath = package.cpath .. ";./build/?.so;../build/?.so"

local computo = require("computo_lua")

print("=== Object Syntax Test ===")

-- Test 1: Basic object syntax
print("1. Testing object syntax:")
local obj = {
    array = {1, 2, 3, 4, 5},
    value = 42,
    nested = {
        name = "test",
        count = 3
    }
}

print("   Object structure:")
print("     array: {1, 2, 3, 4, 5}")
print("     value: 42")
print("     nested: {name='test', count=3}")
print()

-- Test the JSON conversion by executing a simple script
print("2. Testing simple arithmetic (baseline):")
local simple_result = computo.execute({"+", 3, 5})
print("   {'+', 3, 5} =", simple_result)
print()

print("3. Testing with inputs argument:")
local success, result = pcall(function()
    -- Try passing object as inputs to see if it handles it
    return computo.execute({"+", 10, 5}, obj)
end)

if success then
    print("     Inputs parameter accepted! Result:", result)
else
    print("      Error with inputs:", result)
end

print()
print("=== Test Complete ===")
print("Note: Full $input support depends on Computo's implementation")
