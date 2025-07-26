#!/usr/bin/env lua5.4

-- Simple example showing how to use ComputoLua

-- Set up the module path to find our compiled module
-- Add the build directory to package.cpath
package.cpath = package.cpath .. ";./build/?.so;../build/?.so"

-- Load the ComputoLua module
local computo = require("computo_lua")

print("=== ComputoLua Simple Examples ===")
print()

-- Example 1: Basic arithmetic
print("1. Basic Addition:")
print("   Input: {'+', 3, 5}")
local result1 = computo.execute({"+", 3, 5})
print("   Result:", result1)
print()

-- Example 2: Multiple operands
print("2. Multiple Addition:")
print("   Input: {'+', 1, 2, 3, 4}")
local result2 = computo.execute({"+", 1, 2, 3, 4})
print("   Result:", result2)
print()

-- Example 3: Nested operations
print("3. Nested Operations:")
print("   Input: {'*', {'+', 2, 3}, 4}")
local result3 = computo.execute({"*", {"+", 2, 3}, 4})
print("   Result:", result3)
print()

-- Example 4: Division with floating point
print("4. Division:")
print("   Input: {'/', 15, 4}")
local result4 = computo.execute({"/", 15, 4})
print("   Result:", result4)
print()

-- Example 5: More complex nested expression
print("5. Complex Expression:")
print("   Input: {'+', {'*', 2, 3}, {'/', 8, 2}}")
local result5 = computo.execute({"+", {"*", 2, 3}, {"/", 8, 2}})
print("   Result:", result5, "(should be 10)")
print()

-- Example 6: Error handling
print("6. Error Handling:")
print("   Input: {'invalid_op', 1, 2}")
local success, error_msg = pcall(function()
    return computo.execute({"invalid_op", 1, 2})
end)
if not success then
    print("   Caught error:", error_msg)
else
    print("   Unexpected success!")
end
print()

print("=== All examples completed! ===")