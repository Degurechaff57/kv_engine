cmake_minimum_required(VERSION 3.20)

project(hello_world LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(show_ip)
target_sources(show_ip PRIVATE src/show_ip.cc)

add_executable(server_bj)
target_sources(server_bj PRIVATE src/bj_server.cc)
add_executable(client_bj)
target_sources(client_bj PRIVATE src/bj_client.cc)

add_executable(echo_server)
target_sources(echo_server PRIVATE src/echo_server.cc)

add_executable(echo_client)
target_sources(echo_client PRIVATE src/echo_client.cc)
