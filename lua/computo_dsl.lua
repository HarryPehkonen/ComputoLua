-- Computo DSL for Lua
-- Provides an idiomatic Lua interface for building Computo scripts

-- Load the core ComputoLua binding
-- Set up module path to find the compiled binary
package.cpath = package.cpath .. ";./build/?.so;../build/?.so"
local computo_core = require("computo_lua")

local M = {}

-- Helper function to create operator expressions
local function op(operator, ...)
    local args = {...}
    local result = {operator}
    for _, arg in ipairs(args) do
        table.insert(result, arg)
    end
    return result
end

-- Arithmetic operators
function M.add(...) return op("+", ...) end
function M.sub(...) return op("-", ...) end
function M.mul(...) return op("*", ...) end
function M.div(...) return op("/", ...) end
function M.mod(...) return op("%", ...) end

-- Comparison operators  
function M.gt(a, b) return op(">", a, b) end
function M.lt(a, b) return op("<", a, b) end
function M.gte(a, b) return op(">=", a, b) end
function M.lte(a, b) return op("<=", a, b) end
function M.eq(a, b) return op("==", a, b) end
function M.neq(a, b) return op("!=", a, b) end

-- Logical operators
function M.and_op(...) return op("and", ...) end
function M.or_op(...) return op("or", ...) end
function M.not_op(a) return op("not", a) end

-- Data access
function M.var(path) return {"$", path} end
function M.input(path) 
    if path then
        return {"$input", path}
    else
        return {"$input"}
    end
end

-- Control flow
function M.if_then_else(condition, then_expr, else_expr)
    return {"if", condition, then_expr, else_expr}
end

-- Lambda expressions
function M.lambda(params, body)
    -- params should be an array of parameter names
    -- body should be the expression
    return {"lambda", params, body}
end

-- Let expressions for variable binding
function M.let(bindings, body)
    -- bindings should be a table like {var1 = expr1, var2 = expr2}
    -- Convert to Computo let format: ["let", [["var1", expr1], ["var2", expr2]], body]
    local binding_list = {}
    for var_name, expr in pairs(bindings) do
        table.insert(binding_list, {var_name, expr})
    end
    return {"let", binding_list, body}
end

-- Functional operations
function M.map(array_expr, func_expr)
    return {"map", array_expr, func_expr}
end

function M.filter(array_expr, predicate_expr)
    return {"filter", array_expr, predicate_expr}
end

function M.reduce(array_expr, init_expr, func_expr)
    return {"reduce", array_expr, init_expr, func_expr}
end

-- Array operations
function M.car(array_expr)
    return {"car", array_expr}
end

function M.cdr(array_expr)
    return {"cdr", array_expr}
end

function M.cons(elem_expr, array_expr)
    return {"cons", elem_expr, array_expr}
end

function M.append(...)
    return op("append", ...)
end

-- Object operations (if Computo supports them)
function M.get(obj_expr, key)
    return {"get", obj_expr, key}
end

function M.set(obj_expr, key, value_expr)
    return {"set", obj_expr, key, value_expr}
end

-- String operations (if Computo supports them)
function M.concat(...)
    return op("concat", ...)
end

function M.length(expr)
    return {"length", expr}
end

-- Convenience function to build and execute in one call
function M.execute(script_expr, input_data)
    local inputs = {}
    if input_data then
        table.insert(inputs, input_data)
    end
    
    -- Use the core binding to execute
    return computo_core.execute(script_expr)
end

-- Alternative execute that takes explicit inputs array
function M.execute_with_inputs(script_expr, inputs_array)
    -- Note: Current binding doesn't support inputs array yet
    -- This is a placeholder for future enhancement
    return computo_core.execute(script_expr)
end

-- Metatable magic to allow operator overloading (optional enhancement)
local expression_mt = {
    __add = function(a, b) return M.add(a, b) end,
    __sub = function(a, b) return M.sub(a, b) end,
    __mul = function(a, b) return M.mul(a, b) end,
    __div = function(a, b) return M.div(a, b) end,
    __mod = function(a, b) return M.mod(a, b) end,
}

-- Function to make expressions support operator overloading
function M.expr(value)
    local expr = {value}
    setmetatable(expr, expression_mt)
    return expr
end

-- Debug helper to pretty-print expressions
function M.pretty_print(expr, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    
    if type(expr) ~= "table" then
        return tostring(expr)
    end
    
    if #expr == 0 then
        -- Empty table or object
        return "{}"
    end
    
    local result = "{\n"
    for i, v in ipairs(expr) do
        result = result .. spaces .. "  " .. M.pretty_print(v, indent + 1)
        if i < #expr then
            result = result .. ","
        end
        result = result .. "\n"
    end
    result = result .. spaces .. "}"
    return result
end

return M