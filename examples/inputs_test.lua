#!/usr/bin/env lua5.4

-- Test script for inputs support and object syntax

local C = require("lua.computo_dsl")

print("=== Input Data and Object Syntax Tests ===")
print()

-- Test 1: Basic inputs support
print("1. Testing $input with data:")
local input_data = {
    users = {
        {name = "Alice", age = 25},
        {name = "Bob", age = 35},
        {name = "Charlie", age = 40}
    }
}

print("   Input data:")
for i, user in ipairs(input_data.users) do
    print(string.format("     %s (age %d)", user.name, user.age))
end

-- Try to access input data
local script_with_input = C.input("/users") 
print("   Script: C.input('/users')")
print("   Generated JSON:", C.pretty_print(script_with_input))

local success, result = pcall(function()
    return C.execute(script_with_input, input_data)
end)

if success then
    print("     Input access successful!")
    if type(result) == "table" then
        print("   Result: table with", #result, "users")
    else
        print("   Result:", result)
    end
else
    print("      Input access result:", result)
end
print()

-- Test 2: Object syntax {"array": [...]}
print("2. Testing object syntax {\"array\": [...]}")
local object_syntax = {
    array = {1, 2, 3, 4, 5}
}

print("   Input object:")
print("     array: {1, 2, 3, 4, 5}")

local success2, result2 = pcall(function()
    return C.execute(C.input("/array"), object_syntax)
end)

if success2 then
    print("     Object syntax works!")
    if type(result2) == "table" then
        print("   Result: array with", #result2, "elements")
        print("   Values:", table.concat(result2, ", "))
    else
        print("   Result:", result2)
    end
else
    print("      Object syntax result:", result2)
end
print()

-- Test 3: Multiple inputs (array of inputs)
print("3. Testing multiple inputs:")
local inputs_array = {
    {numbers = {1, 2, 3}},
    {numbers = {4, 5, 6}}
}

print("   Multiple inputs:")
print("     Input 1: {numbers = {1, 2, 3}}")
print("     Input 2: {numbers = {4, 5, 6}}")

-- Try to access first input
local multi_input_script = C.input("/numbers")
local success3, result3 = pcall(function()
    return C.execute_with_inputs(multi_input_script, inputs_array)
end)

if success3 then
    print("     Multiple inputs work!")
    if type(result3) == "table" then
        print("   Result from first input:", table.concat(result3, ", "))
    else
        print("   Result:", result3)
    end
else
    print("      Multiple inputs result:", result3)
end
print()

-- Test 4: Direct low-level binding test
print("4. Testing low-level binding directly:")
local computo_core = require("computo_lua")

-- Test basic execution without inputs
local basic_result = computo_core.execute({"+", 10, 5})
print("   Basic execution: {'+', 10, 5} =", basic_result)

-- Test execution with inputs
local success4, input_result = pcall(function()
    return computo_core.execute({"$input", "/value"}, {value = 42})
end)

if success4 then
    print("     Low-level inputs work! Result:", input_result)
else
    print("      Low-level inputs result:", input_result)
end
print()

print("=== Tests Complete ===")
print()
print("Notes:")
print("- Input support requires Computo to handle $input operators")
print("- Object syntax {\"key\": value} should work with JSON conversion")
print("- Multiple inputs may need specific Computo script syntax")
print("- Some features may be pending Computo's input implementation")
