cmake_minimum_required(VERSION 3.16)
project(yosina-icu4c-examples LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(ICU REQUIRED IMPORTED_TARGET icu-uc icu-i18n)

add_executable(basic_usage basic_usage.cpp)
target_link_libraries(basic_usage PRIVATE PkgConfig::ICU)
