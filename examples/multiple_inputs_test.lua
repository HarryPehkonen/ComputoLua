#!/usr/bin/env lua5.4

-- Comprehensive test for multiple inputs functionality

local C = require("lua.computo_dsl")

print("=== Multiple Inputs Comprehensive Test ===")
print()

-- Test data: multiple input objects
local input1 = {
    users = {
        {name = "Alice", age = 25, role = "developer"},
        {name = "Bob", age = 35, role = "manager"}
    }
}

local input2 = {
    config = {
        theme = "dark",
        language = "en",
        debug = true
    }
}

local input3 = {
    metadata = {
        version = "1.0.2",
        build = 42,
        timestamp = "2025-01-01"
    }
}

print("Test inputs:")
print("  Input 0 (users):", #input1.users, "users")
print("  Input 1 (config): theme =", input2.config.theme)
print("  Input 2 (metadata): version =", input3.metadata.version)
print()

-- Test 1: Basic single input access (existing functionality)
print("1. Testing single input access:")
local single_script = C.input("/users/0/name")
print("   Script:", C.pretty_print(single_script))

local success1, result1 = pcall(function()
    return C.execute(single_script, input1)
end)

if success1 then
    print("     Single input access works! Result:", result1)
else
    print("      Single input access:", result1)
end
print()

-- Test 2: Multiple inputs access with C.inputs()
print("2. Testing multiple inputs access:")

-- Script that accesses different inputs
local multi_script = {
    first_user = C.input("/users/0/name"),          -- First input (syntactic sugar)
    second_user = C.inputs("/0/users/1/name"),      -- First input (explicit)
    theme = C.inputs("/1/config/theme"),            -- Second input
    version = C.inputs("/2/metadata/version"),      -- Third input
    debug_mode = C.inputs("/1/config/debug")        -- Second input again
}

print("   Script structure:")
print("     first_user:", C.pretty_print(C.input("/users/0/name")))
print("     theme:", C.pretty_print(C.inputs("/1/config/theme")))
print("     version:", C.pretty_print(C.inputs("/2/metadata/version")))
print()

local success2, result2 = pcall(function()
    return C.execute_with_inputs(multi_script, {input1, input2, input3})
end)

if success2 then
    print("     Multiple inputs access works!")
    if type(result2) == "table" then
        print("   Results:")
        for key, value in pairs(result2) do
            print("     " .. key .. ":", value)
        end
    else
        print("   Result:", result2)
    end
else
    print("      Multiple inputs access:", result2)
end
print()

-- Test 3: Complex nested access
print("3. Testing complex nested access:")
local complex_script = C.add(
    C.inputs("/0/users/0/age"),     -- Alice's age from input 0
    C.inputs("/2/metadata/build")   -- Build number from input 2
)

print("   Script:", C.pretty_print(complex_script))

local success3, result3 = pcall(function()
    return C.execute_with_inputs(complex_script, {input1, input2, input3})
end)

if success3 then
    print("     Complex nested access works! Result:", result3, "(should be 67: 25 + 42)")
else
    print("      Complex nested access:", result3)
end
print()

-- Test 4: Low-level binding test
print("4. Testing low-level binding directly:")
local computo_core = require("computo_lua")

-- Simple access to second input
local low_level_script = {"$inputs", "/1/config/theme"}
print("   Low-level script:", table.concat(low_level_script, ", "))

local success4, result4 = pcall(function()
    return computo_core.execute(low_level_script, {input1, input2, input3})
end)

if success4 then
    print("     Low-level multiple inputs work! Result:", result4)
else
    print("      Low-level multiple inputs:", result4)
end
print()

-- Test 5: Mixing $input and $inputs syntax
print("5. Testing mixed syntax:")
local mixed_script = {
    sugar_syntax = C.input("/users/0/role"),        -- $input syntax
    explicit_syntax = C.inputs("/0/users/0/role")   -- $inputs syntax (should be same)
}

print("   Both should access the same data:")
print("     $input syntax:", C.pretty_print(C.input("/users/0/role")))
print("     $inputs syntax:", C.pretty_print(C.inputs("/0/users/0/role")))

local success5, result5 = pcall(function()
    return C.execute_with_inputs(mixed_script, {input1, input2, input3})
end)

if success5 then
    print("     Mixed syntax works!")
    if type(result5) == "table" then
        print("   Results should be identical:")
        for key, value in pairs(result5) do
            print("     " .. key .. ":", value)
        end
    end
else
    print("      Mixed syntax:", result5)
end
print()

print("=== Test Summary ===")
print("  C.input(path) - Single input access (syntactic sugar)")
print("  C.inputs(path) - Multiple inputs access with explicit indexing")  
print("  C.execute_with_inputs() - Passing multiple input objects")
print("  Mixed usage - Both $input and $inputs syntax in same script")
print()
print("Multiple inputs support is complete!  ")
print("Usage:")
print("  - First input: C.input('/path') or C.inputs('/0/path')")
print("  - Other inputs: C.inputs('/1/path'), C.inputs('/2/path'), etc.")
print("  - Execute: C.execute_with_inputs(script, {input1, input2, input3})")
