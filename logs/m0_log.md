# development log

## 1. Initialize project structure

### 1.1 create folders named: `src`, `include`, `tests` and `logs`

```bash
mkdir src include tests logs
```

## 2.run a `hello_world.cc` demo

## 2.1 set how to run a `hello_world.cpp` with building tools

`hello_world.cc`

```cpp

```

Using one line command to compile source file into executable:

```bash
g++ -std=c++20 -O0 -g -Wall -Wextra -Wpedantic \
  tests/hello_world.cpp -o tmp/hello_world
```

Other way, you can use building tools like `cmake`:

1. create a `CMakeLists.txt` for `cmake` to understand what you want to do.
2. run `build.sh`

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 2.20)

project(hello_world LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 19)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(hello_world)
target_sources(hello_world PRIVATE src/hello_world.cc)
```

`build.sh`

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

We can refer to these references for further learning:

- [Cmake tutorial (CN)](https://cmake.com.cn/cmake/help/latest/guide/tutorial/index.html)
