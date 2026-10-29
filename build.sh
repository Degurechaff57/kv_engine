rm -rf build
cmake -S . -B build -G Ninja
cmake --build build
./build/show_ip www.example.com
./build/show_ip ipv6.example.com
