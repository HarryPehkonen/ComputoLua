#!/usr/bin/env lua5.4

-- Example of using the Computo DSL for idiomatic Lua scripting

-- Load the DSL
local C = require("lua.computo_dsl")

print("=== Computo DSL Examples ===")
print()

-- Example 1: Basic arithmetic with DSL
print("1. Basic arithmetic with DSL:")
local simple_add = C.add(3, 5)
print("   Expression:", C.pretty_print(simple_add))
local result1 = C.execute(simple_add)
print("   Result:", result1)
print()

-- Example 2: More complex arithmetic
print("2. Complex arithmetic:")
local complex_expr = C.add(C.mul(2, 3), C.div(8, 2))
print("   Expression:", C.pretty_print(complex_expr))
local result2 = C.execute(complex_expr)
print("   Result:", result2, "(should be 10)")
print()

-- Example 3: Comparison operations
print("3. Comparison:")
local comparison = C.gt(10, 5)
print("   Expression:", C.pretty_print(comparison))
local result3 = C.execute(comparison)
print("   Result:", result3, "(should be true)")
print()

-- Example 4: Conditional logic
print("4. Conditional (if-then-else):")
local conditional = C.if_then_else(C.gt(10, 5), "greater", "not greater")
print("   Expression:", C.pretty_print(conditional))
local result4 = C.execute(conditional)
print("   Result:", result4)
print()

-- Example 5: Working with arrays (basic)
print("5. Array operations:")
local test_array = {1, 2, 3, 4, 5}
print("   Test array:", table.concat(test_array, ", "))

-- Get first element (car)
local first_elem = C.car(test_array)
print("   First element expression:", C.pretty_print(first_elem))
-- Note: This might not work with current Computo setup, but shows the DSL structure
print()

-- Example 6: Variable usage
print("6. Variable usage:")
local var_expr = C.let({x = 10, y = 5}, C.add(C.var("/x"), C.var("/y")))
print("   Expression:", C.pretty_print(var_expr))
-- Note: This requires Computo's let binding support
print()

-- Example 7: Lambda expression structure
print("7. Lambda expression (structure only):")
local lambda_expr = C.lambda({"x"}, C.mul(C.var("/x"), 2))
print("   Expression:", C.pretty_print(lambda_expr))
print()

-- Example 8: Map operation structure  
print("8. Map operation (structure only):")
local map_expr = C.map({1, 2, 3}, C.lambda({"x"}, C.mul(C.var("/x"), 2)))
print("   Expression:", C.pretty_print(map_expr))
print()

print("=== DSL Structure Examples Complete ===")
print()
print("Note: Some advanced operations like let, lambda, and map may require")
print("additional Computo features or input data handling to execute properly.")
print("The DSL successfully creates the correct JSON structure for Computo!")