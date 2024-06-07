cmake_minimum_required(VERSION 3.10) 
project(lab03) 
set(CMAKE_CXX_STANDARD 14)

include(FindFLEX) 
include(FindBISON)

if(FLEX_FOUND) 
    message("Info: flex found!")
else() 
    message("Error: flex not found!")
endif()

if(BISON_FOUND)
    message("Info: bison found!")
else()
    message("Error: bison not found!")
endif()

include_directories(${CMAKE_SOURCE_DIR}) 
include_directories(${CMAKE_BINARY_DIR})

# Set debug build type
set(CMAKE_BUILD_TYPE Debug)

# Add debug options
add_compile_options(-g -DYYDEBUG=1) # Add -DYYDEBUG=1 to enable Bison debug mode
add_compile_options(-pedantic)

# Flex and Bison targets
FLEX_TARGET(MyLexer lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.c)
BISON_TARGET(MyParser grammar.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c COMPILE_FLAGS "-t -v")
ADD_FLEX_BISON_DEPENDENCY(MyLexer MyParser) 

# add_compile_options(-fsanitize=address) 
# add_link_options(-fsanitize=address)
add_compile_options(-pedantic) 

add_executable(
    Compilerlab3 
    ${FLEX_MyLexer_OUTPUTS}
    ${BISON_MyParser_OUTPUTS}
)
target_compile_features(Compilerlab3 PRIVATE cxx_std_14)

# Ensure project rebuilds when debugging
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT Compilerlab3)