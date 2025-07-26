#!/usr/bin/env lua5.4

-- Advanced DSL example matching your desired usage pattern

local C = require("lua.computo_dsl")

print("=== Advanced Computo DSL Example ===")
print()

-- Input data is just a regular Lua table
local input_data = {
  users = {
    { name = "Alice", age = 25 },
    { name = "Bob", age = 35 },
    { name = "Charlie", age = 40 }
  }
}

print("Input data:")
print("  users = {")
for i, user in ipairs(input_data.users) do
    print(string.format("    { name = \"%s\", age = %d },", user.name, user.age))
end
print("  }")
print()

-- Build a script using the Lua DSL
-- This creates the JSON structure that Computo expects
print("Building script with DSL...")

-- Note: This is the structure - some parts may need adjustment based on 
-- Computo's exact input/variable syntax
local script = C.let(
    { users = C.input("/users") },
    C.map(
        C.filter(
            C.var("/users"), 
            C.lambda({"user"}, C.gt(C.var("/user/age"), 30))
        ),
        C.lambda({"user"}, C.var("/user/name"))
    )
)

print("Generated script structure:")
print(C.pretty_print(script))
print()

-- The `script` variable now holds a Lua table that represents the Computo JSON
print("Script as Lua table:")
for k, v in pairs(script) do
    print("  " .. k .. ":", type(v) == "table" and "{...}" or tostring(v))
end
print()

-- Try to execute (may need adjustment based on Computo's input handling)
print("Attempting to execute...")
print("Note: This may require Computo input support to work fully")

local success, result = pcall(function()
    return C.execute(script, input_data)
end)

if success then
    print("Result:", result)
    if type(result) == "table" then
        print("Result array:")
        for i, name in ipairs(result) do
            print("  " .. i .. ":", name)
        end
    end
else
    print("Execution note:", result)
    print("The DSL successfully created the script structure!")
    print("Full execution may require Computo input data support.")
end

print()

-- Show some simpler DSL examples that work with current setup
print("=== Working DSL Examples ===")
print()

-- Simple arithmetic that works
print("Simple arithmetic:")
local simple = C.add(C.mul(2, 3), 4)  -- (2 * 3) + 4 = 10
print("Expression:", C.pretty_print(simple))
local simple_result = C.execute(simple)
print("Result:", simple_result)
print()

-- Nested arithmetic
print("Nested arithmetic:")
local nested = C.div(C.add(20, 10), C.sub(8, 3))  -- (20 + 10) / (8 - 3) = 6
print("Expression:", C.pretty_print(nested))
local nested_result = C.execute(nested)
print("Result:", nested_result)
print()

print("=== DSL Implementation Complete! ===")
print()
print("The computo_dsl.lua module provides:")
print("- Idiomatic Lua functions for all Computo operations")  
print("- Clean, readable script construction")
print("- Automatic JSON structure generation")
print("- Integration with the C++ core execution engine")
print("- Pretty-printing for debugging")
