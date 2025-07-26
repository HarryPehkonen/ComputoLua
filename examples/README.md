# ComputoLua Usage Examples

## Quick Start

After building ComputoLua, you have a shared library `computo_lua.so` in the `build/` directory.

### Method 1: Run from project directory

```bash
# From the ComputoLua root directory
lua5.4 examples/simple.lua
lua5.4 tests/test_basic.lua
```

The scripts automatically add `./build/` to the module search path.

### Method 2: Copy module to system location

```bash
# Copy to Lua's module directory (may need sudo)
sudo cp build/computo_lua.so /usr/local/lib/lua/5.4/

# Then use from anywhere
lua5.4 -e "local computo = require('computo_lua'); print(computo.execute({'+', 3, 5}))"
```

### Method 3: Set LUA_CPATH environment variable

```bash
# Add build directory to Lua's C module search path
export LUA_CPATH="./build/?.so;$LUA_CPATH"
lua5.4 examples/simple.lua
```

### Method 4: Specify path in Lua script

```lua
-- At the top of your Lua script
package.cpath = package.cpath .. ";/path/to/ComputoLua/build/?.so"
local computo = require("computo_lua")
```

## Basic Usage

```lua
local computo = require("computo_lua")

-- Simple arithmetic
local result = computo.execute({"+", 3, 5})  -- Returns 8

-- Nested operations  
local result = computo.execute({"*", {"+", 2, 3}, 4})  -- Returns 20

-- Multiple operands
local result = computo.execute({"+", 1, 2, 3, 4})  -- Returns 10
```

## Available Examples

- **`simple.lua`** - Basic arithmetic operations and error handling
- **`test_basic.lua`** - Comprehensive test suite with assertions

## Error Handling

ComputoLua converts C++ exceptions to Lua errors:

```lua
local success, error_msg = pcall(function()
    return computo.execute({"invalid_operator", 1, 2})
end)

if not success then
    print("Error:", error_msg)
end
```