# ComputoLua

**Lua bindings for the Computo computational engine**

ComputoLua provides both low-level C bindings and a high-level Lua DSL for the [Computo](https://github.com/HarryPehkonen/Computo) data transformation engine. Execute JSON-native functional programming operations with an idiomatic Lua interface.

## Features

- **Fast C++ core** - Direct binding to Computo engine
- **Lua C API** - Lightweight, stable integration  
- **Idiomatic DSL** - Clean Lua syntax for script construction
- **Automatic conversion** - Seamless Lua table ↔ JSON translation
- **Functional programming** - map, filter, reduce, lambda expressions
- **Error handling** - C++ exceptions become Lua errors
- **Easy installation** - CMake build with system integration

## Quick Start

```lua
-- Load the DSL
local C = require("lua.computo_dsl")

-- Simple arithmetic
local result = C.execute(C.add(3, 5))
print(result)  -- 8.0

-- Complex nested operations
local script = C.mul(C.add(2, 3), C.div(8, 2))
print(C.execute(script))  -- 20.0

-- Functional programming with variables
local advanced = C.let({x = 10, y = 5}, 
    C.add(C.var("/x"), C.var("/y")))
print(C.execute(advanced))  -- 15.0
```

## Requirements

- **CMake** 3.15+
- **C++17** compliant compiler (GCC, Clang)
- **Lua 5.4** runtime and development headers

### Ubuntu/Debian Installation

```bash
sudo apt update
sudo apt install cmake build-essential lua5.4 liblua5.4-dev
```

## Build Instructions

```bash
# Clone the repository
git clone https://github.com/HarryPehkonen/ComputoLua
cd ComputoLua

# Configure and build
cmake -B build
cmake --build build

# Optional: Run tests
lua5.4 tests/test_basic.lua
lua5.4 examples/simple.lua
```

### Build Options

```bash
# Enable clang-tidy (requires clang-tidy installed)
cmake -B build -DENABLE_CLANG_TIDY=ON

# Release build
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Custom install prefix
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr/local
```

## Testing

ComputoLua includes comprehensive tests and examples:

```bash
# Basic functionality tests
lua5.4 tests/test_basic.lua

# Simple usage examples  
lua5.4 examples/simple.lua

# DSL demonstrations
lua5.4 examples/dsl_example.lua

# Advanced DSL patterns
lua5.4 examples/advanced_dsl.lua
```

All tests should pass with   markers and "All tests passed!" message.

## Installation

### System-wide Installation

```bash
# Build and install (may require sudo)
cmake --build build
sudo cmake --install build

# Verify installation
lua5.4 -e "print(require('computo_dsl').execute({'+', 3, 5}))"
```

This installs:
- `computo_lua.so` → `/usr/local/lib/lua/5.4/`
- `computo_dsl.lua` → `/usr/local/share/lua/5.4/`

### Development Usage

For development, run from the project directory (no installation needed):

```bash
lua5.4 examples/simple.lua  # Scripts auto-detect ./build/ location
```

## Usage

### Low-Level C Binding

```lua
-- Direct binding to C++ core
local computo = require("computo_lua")

-- Execute JSON-like Lua tables
local result = computo.execute({"+", 3, 5})           -- 8.0
local nested = computo.execute({"*", {"+", 2, 3}, 4}) -- 20.0
```

### High-Level Lua DSL

```lua
-- Idiomatic Lua interface
local C = require("lua.computo_dsl")

-- Build expressions with functions
local expr = C.add(C.mul(2, 3), C.div(8, 2))
local result = C.execute(expr)  -- 10.0
```

## DSL Reference

### Arithmetic Operations

```lua
C.add(a, b, ...)       -- Addition: a + b + ...
C.sub(a, b)            -- Subtraction: a - b  
C.mul(a, b, ...)       -- Multiplication: a * b * ...
C.div(a, b)            -- Division: a / b
C.mod(a, b)            -- Modulo: a % b
```

### Comparison Operations

```lua
C.gt(a, b)             -- Greater than: a > b
C.lt(a, b)             -- Less than: a < b  
C.gte(a, b)            -- Greater than or equal: a >= b
C.lte(a, b)            -- Less than or equal: a <= b
C.eq(a, b)             -- Equal: a == b
C.neq(a, b)            -- Not equal: a != b
```

### Logical Operations

```lua
C.and_op(a, b, ...)    -- Logical AND
C.or_op(a, b, ...)     -- Logical OR  
C.not_op(a)            -- Logical NOT
```

### Control Flow

```lua
C.if_then_else(condition, then_expr, else_expr)
-- Example: C.if_then_else(C.gt(x, 0), "positive", "not positive")
```

### Variables and Data Access

```lua
C.var("/path")         -- Variable reference
C.input("/path")       -- Input data reference
C.let(bindings, body)  -- Variable binding

-- Example:
local script = C.let({x = 10, y = 5}, C.add(C.var("/x"), C.var("/y")))
```

### Lambda Expressions

```lua
C.lambda(params, body)
-- Example: C.lambda({"x"}, C.mul(C.var("/x"), 2))
```

### Functional Programming

```lua
C.map(array, func)         -- Transform each element
C.filter(array, predicate) -- Keep elements matching condition  
C.reduce(array, init, func) -- Accumulate values

-- Example:
local double_odds = C.map(
    C.filter({1,2,3,4,5}, C.lambda({"x"}, C.eq(C.mod(C.var("/x"), 2), 1))),
    C.lambda({"x"}, C.mul(C.var("/x"), 2))
)
```

### Array Operations

```lua
C.car(array)           -- First element
C.cdr(array)           -- Rest of elements
C.cons(elem, array)    -- Prepend element
C.append(arr1, arr2)   -- Concatenate arrays
```

### Utility Functions

```lua
C.execute(expr)           -- Execute expression
C.pretty_print(expr)      -- Debug print expression structure
```

## Examples

### Basic Arithmetic

```lua
local C = require("lua.computo_dsl")

-- Simple calculation
print(C.execute(C.add(10, 20)))  -- 30.0

-- Nested operations  
local complex = C.div(C.add(100, 50), C.sub(20, 5))
print(C.execute(complex))  -- 10.0
```

### Conditional Logic

```lua
local C = require("lua.computo_dsl") 

local age = 25
local category = C.if_then_else(
    C.gte(age, 18),
    "adult", 
    "minor"
)
print(C.execute(category))  -- "adult"
```

### Working with Variables

```lua
local C = require("lua.computo_dsl")

-- Define variables and use them
local calculation = C.let(
    {radius = 5, pi = 3.14159},
    C.mul(C.var("/pi"), C.mul(C.var("/radius"), C.var("/radius")))
)
print(C.execute(calculation))  -- ~78.54 (area of circle)
```

### Error Handling

```lua
local C = require("lua.computo_dsl")

local success, error_msg = pcall(function()
    return C.execute({"invalid_operator", 1, 2})
end)

if not success then
    print("Caught error:", error_msg)
end
```

## Architecture

ComputoLua consists of three layers:

1. **Computo C++ Engine** - Core computational engine (fetched automatically)
2. **C Binding Layer** (`src/lua_bindings.cpp`) - Lua C API integration with JSON conversion
3. **Lua DSL Layer** (`lua/computo_dsl.lua`) - High-level Lua interface

```
┌─────────────────┐
│  Lua DSL        │  ← Clean, idiomatic Lua functions
│  computo_dsl    │
├─────────────────┤
│  C Binding      │  ← JSON ↔ Lua table conversion  
│  computo_lua.so │
├─────────────────┤
│  Computo Engine │  ← Fast C++ computational core
│  (C++)          │
└─────────────────┘
```

## Development

### Code Formatting

```bash
# Format C++ code (requires clang-format)
make format-lua

# Lint C++ code (requires clang-tidy)  
cmake -B build -DENABLE_CLANG_TIDY=ON
cmake --build build
```

### Project Structure

```
ComputoLua/
├── CMakeLists.txt          # Build configuration
├── src/lua_bindings.cpp    # C++ Lua binding implementation
├── lua/computo_dsl.lua     # High-level Lua DSL  
├── tests/test_basic.lua    # Test suite
├── examples/               # Usage examples
│   ├── simple.lua         # Basic usage
│   ├── dsl_example.lua    # DSL demonstrations  
│   └── advanced_dsl.lua   # Complex patterns
├── .clang-format          # Code formatting rules
├── .clang-tidy           # Static analysis rules
└── .gitignore            # Git ignore patterns
```

## Contributing

1. Follow the existing code style (use `make format-lua`)
2. Add tests for new functionality
3. Update documentation for API changes
4. Ensure all tests pass before submitting

## License

This project is released into the public domain. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [Computo](https://github.com/HarryPehkonen/Computo) - Core computational engine
- [Lua](https://www.lua.org/) - Embedded scripting language  
- [nlohmann/json](https://github.com/nlohmann/json) - JSON library
- [CMake](https://cmake.org/) - Build system
