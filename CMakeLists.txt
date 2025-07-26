cmake_minimum_required(VERSION 3.15)
project(ComputoLua VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find system Lua 5.4
find_package(Lua REQUIRED)

# Include FetchContent module
include(FetchContent)

# No need for sol2 - using Lua C API directly

# Fetch Computo computational engine
FetchContent_Declare(
    Computo
    GIT_REPOSITORY https://github.com/HarryPehkonen/Computo.git
    GIT_TAG        main
)

# Set position-independent code for Computo before making it available
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
FetchContent_MakeAvailable(Computo)

# Ensure Computo library has PIC enabled for shared library linking
set_property(TARGET computo PROPERTY POSITION_INDEPENDENT_CODE ON)

# Create the Lua module as a shared library
add_library(computo_lua SHARED
    src/lua_bindings.cpp
)

# Link dependencies
target_link_libraries(computo_lua PRIVATE
    ${LUA_LIBRARIES}
    computo
)

# Include directories
target_include_directories(computo_lua PRIVATE
    ${LUA_INCLUDE_DIR}
)

# Set module properties for Lua
set_target_properties(computo_lua PROPERTIES
    PREFIX ""                    # Remove 'lib' prefix for Lua modules
    OUTPUT_NAME "computo_lua"    # Final module name
    CXX_STANDARD 17
)

# Install targets
# Install the compiled C module
install(TARGETS computo_lua
        LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/lua/5.4/
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/lua/5.4/)

# Install Lua DSL module
install(FILES lua/computo_dsl.lua 
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/lua/5.4/)

# Compiler options for clean builds
target_compile_options(computo_lua PRIVATE
    -Wall -Wextra -Wpedantic
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)

# --- Code Quality Tools ---

# Find clang-format
find_program(CLANG_FORMAT_EXECUTABLE
    NAMES clang-format clang-format-14 clang-format-13 clang-format-12
    DOC "Path to clang-format executable"
)

# Find clang-tidy
find_program(CLANG_TIDY_EXECUTABLE
    NAMES clang-tidy clang-tidy-14 clang-tidy-13 clang-tidy-12
    DOC "Path to clang-tidy executable"
)

# Add clang-tidy to the build if available (disabled for initial development)
if(CLANG_TIDY_EXECUTABLE AND FALSE)  # Temporarily disabled
    set_property(TARGET computo_lua PROPERTY CXX_CLANG_TIDY
        "${CLANG_TIDY_EXECUTABLE};--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy"
    )
    message(STATUS "clang-tidy found: ${CLANG_TIDY_EXECUTABLE}")
else()
    message(STATUS "clang-tidy disabled for initial development")
endif()

# Add format target if clang-format is available
if(CLANG_FORMAT_EXECUTABLE)
    file(GLOB_RECURSE ALL_SOURCE_FILES
        ${CMAKE_SOURCE_DIR}/src/*.cpp
        ${CMAKE_SOURCE_DIR}/src/*.hpp
    )
    
    add_custom_target(format-lua
        COMMAND ${CLANG_FORMAT_EXECUTABLE} -i ${ALL_SOURCE_FILES}
        COMMENT "Running clang-format on ComputoLua source files"
        VERBATIM
    )
    
    message(STATUS "clang-format found: ${CLANG_FORMAT_EXECUTABLE}")
    message(STATUS "Use 'make format-lua' to format ComputoLua code")
else()
    message(WARNING "clang-format not found")
endif()