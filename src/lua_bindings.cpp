#include <computo.hpp>
#include <nlohmann/json.hpp>
#include <lua.hpp>
#include <iostream>
#include <stdexcept>
#include <string>

using json = nlohmann::json;

namespace {

// Convert Lua value at stack index to JSON
auto lua_value_to_json(lua_State* lua_state, int index) -> json {
    switch (lua_type(lua_state, index)) {
    case LUA_TNIL:
        return json(nullptr);
        
    case LUA_TBOOLEAN:
        return json(lua_toboolean(lua_state, index) != 0);
        
    case LUA_TNUMBER:
        if (lua_isinteger(lua_state, index)) {
            return json(lua_tointeger(lua_state, index));
        }
        return json(lua_tonumber(lua_state, index));
        
    case LUA_TSTRING:
        return json(lua_tostring(lua_state, index));
        
    case LUA_TTABLE: {
        // Check if it's an array (sequential integer keys starting from 1)
        bool is_array = true;
        int array_size = 0;
        
        // Get table length for arrays
        lua_len(lua_state, index);
        int len = lua_tointeger(lua_state, -1);
        lua_pop(lua_state, 1);
        
        if (len > 0) {
            // Verify it's actually an array by checking all keys 1..len exist
            for (int i = 1; i <= len; ++i) {
                lua_pushinteger(lua_state, i);
                lua_gettable(lua_state, index < 0 ? index - 1 : index);
                if (lua_type(lua_state, -1) == LUA_TNIL) {
                    is_array = false;
                    lua_pop(lua_state, 1);
                    break;
                }
                lua_pop(lua_state, 1);
            }
            array_size = len;
        } else {
            is_array = false;
        }
        
        if (is_array && array_size > 0) {
            // Convert as JSON array
            json result = json::array();
            for (int i = 1; i <= array_size; ++i) {
                lua_pushinteger(lua_state, i);
                lua_gettable(lua_state, index < 0 ? index - 1 : index);
                result.push_back(lua_value_to_json(lua_state, -1));
                lua_pop(lua_state, 1);
            }
            return result;
        } else {
            // Convert as JSON object
            json result = json::object();
            lua_pushnil(lua_state);  // First key
            while (lua_next(lua_state, index < 0 ? index - 1 : index) != 0) {
                // Key is at -2, value is at -1
                std::string key;
                if (lua_type(lua_state, -2) == LUA_TSTRING) {
                    key = lua_tostring(lua_state, -2);
                } else if (lua_type(lua_state, -2) == LUA_TNUMBER) {
                    if (lua_isinteger(lua_state, -2)) {
                        key = std::to_string(lua_tointeger(lua_state, -2));
                    } else {
                        key = std::to_string(lua_tonumber(lua_state, -2));
                    }
                } else {
                    lua_pop(lua_state, 2); // Pop value and key
                    throw std::runtime_error("Invalid table key type");
                }
                
                result[key] = lua_value_to_json(lua_state, -1);
                lua_pop(lua_state, 1); // Remove value, keep key for next iteration
            }
            return result;
        }
    }
    
    default:
        throw std::runtime_error("Unsupported Lua type for JSON conversion");
    }
}

// Push JSON value onto Lua stack
auto json_to_lua_value(lua_State* lua_state, const json& json_val) -> void {
    switch (json_val.type()) {
    case json::value_t::null:
        lua_pushnil(lua_state);
        break;
        
    case json::value_t::boolean:
        lua_pushboolean(lua_state, json_val.get<bool>() ? 1 : 0);
        break;
        
    case json::value_t::number_integer:
        lua_pushinteger(lua_state, json_val.get<lua_Integer>());
        break;
        
    case json::value_t::number_unsigned:
        lua_pushinteger(lua_state, static_cast<lua_Integer>(json_val.get<uint64_t>()));
        break;
        
    case json::value_t::number_float:
        lua_pushnumber(lua_state, json_val.get<lua_Number>());
        break;
        
    case json::value_t::string:
        lua_pushstring(lua_state, json_val.get<std::string>().c_str());
        break;
        
    case json::value_t::array:
        lua_createtable(lua_state, static_cast<int>(json_val.size()), 0);
        for (size_t i = 0; i < json_val.size(); ++i) {
            lua_pushinteger(lua_state, static_cast<lua_Integer>(i + 1)); // Lua arrays are 1-indexed
            json_to_lua_value(lua_state, json_val[i]);
            lua_settable(lua_state, -3);
        }
        break;
        
    case json::value_t::object:
        lua_createtable(lua_state, 0, static_cast<int>(json_val.size()));
        for (const auto& pair : json_val.items()) {
            lua_pushstring(lua_state, pair.key().c_str());
            json_to_lua_value(lua_state, pair.value());
            lua_settable(lua_state, -3);
        }
        break;
        
    default:
        throw std::runtime_error("Unsupported JSON type for Lua conversion");
    }
}

} // anonymous namespace

// Lua function: computo.execute(script_table) or computo.execute(script_table, inputs_array)
extern "C" int lua_computo_execute(lua_State* lua_state) {
    try {
        // Check argument count
        int argc = lua_gettop(lua_state);
        if (argc < 1 || argc > 2) {
            return luaL_error(lua_state, "execute() expects 1 or 2 arguments, got %d", argc);
        }
        
        // Check that first argument is a table
        if (!lua_istable(lua_state, 1)) {
            return luaL_error(lua_state, "execute() first argument (script) must be a table");
        }
        
        // Convert Lua table to JSON
        json script = lua_value_to_json(lua_state, 1);
        
        // Handle optional inputs argument
        std::vector<json> inputs;
        if (argc == 2) {
            if (lua_istable(lua_state, 2)) {
                // Convert inputs table to JSON array
                json inputs_json = lua_value_to_json(lua_state, 2);
                if (inputs_json.is_array()) {
                    // Convert JSON array to vector
                    for (const auto& input : inputs_json) {
                        inputs.push_back(input);
                    }
                } else {
                    // Single input object
                    inputs.push_back(inputs_json);
                }
            } else if (!lua_isnil(lua_state, 2)) {
                return luaL_error(lua_state, "execute() second argument (inputs) must be a table or nil");
            }
        }
        
        // Execute using Computo with inputs
        json result = computo::execute(script, inputs);
        
        // Convert result back to Lua and push onto stack
        json_to_lua_value(lua_state, result);
        
        return 1; // Return 1 value
        
    } catch (const std::exception& exception) {
        return luaL_error(lua_state, "Computo execution error: %s", exception.what());
    }
}

// Module entry point
extern "C" int luaopen_computo_lua(lua_State* lua_state) {
    // Create the module table
    lua_createtable(lua_state, 0, 1); // 0 array elements, 1 hash element
    
    // Register the execute function
    lua_pushstring(lua_state, "execute");
    lua_pushcfunction(lua_state, lua_computo_execute);
    lua_settable(lua_state, -3);
    
    return 1; // Return 1 value (the module table)
}