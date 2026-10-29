# Development Log

## 1. Initialize project structure

### 1.1 Create folders named `src`, `include`, `tests` and `logs`

```bash
mkdir src include tests logs
```

## 2. Run the `hello_world.cc` demo

## 2.1 How to run `hello_world.cpp` with build tools

`hello_world.cc`

Using a one-line command to compile the source file into an executable:

```bash
g++ -std=c++20 -O0 -g -Wall -Wextra -Wpedantic \
  tests/hello_world.cpp -o tmp/hello_world
```

Alternatively, you can use a build tool such as `cmake`:

1. Create a `CMakeLists.txt` for `cmake` to understand what you want to do.
2. Run `build.sh`.

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.20)

project(hello_world LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
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

We can consult the following references for further learning:

- [CMake tutorial (CN)](https://cmake.com.cn/cmake/help/latest/guide/tutorial/index.html)

## 3. Preparation for writing the echo server code

First, we remove the files related to the Hello World demo:

- src/hello_world.cc

### 3.1 How network programming works in C/C++

I would like to recommend this brief tutorial:

- [Beej's Guide to Network Programming](https://beej.us/guide/bgnet/)

After reading it, you will understand the essential concepts for network programming:

- socket, stream sockets, datagram sockets
- ISO/OSI network model
- IP address, IPv4, IPv6
- network, subnet, host, netmask, port
- network byte order, host byte order
- system-call API

### 3.2 Important system-call APIs for network programming

Headers:

- sys/socket.h: socket(), setsockopt(), getsockopt(), bind(), listen(), accept(), connect(), send(), recv(), struct sockaddr
- sys/types.h: ssize_t, socklen_t, pid_t
- unistd.h: read(), write(), close(), fork()
- fcntl.h: fcntl(), O_NONBLOCK
- netinet/in.h: struct sockaddr_in (IPv4), sockaddr_in6 (IPv6), in_addr; INADDR_ANY, IPPROTO_TCP
- arpa/inet.h: inet_ntop(), inet_pton(), htonl(), htons()
- netdb.h: getaddrinfo(), freeaddrinfo(), gai_strerror(); struct addrinfo, hostent

These headers provide the basic interfaces for sending and receiving messages to and from a hostname.

In most cases, the code follows this framework:

`TCP network programming framework`

```
Server                                      Client
──────                                      ──────
getaddrinfo(NULL, port, AI_PASSIVE)         getaddrinfo(host, port)
   │  "I want to listen; give me a wildcard address"   │  "I want to connect; give me the target address"
   ▼                                                   ▼
socket()  → returns an fd                   socket()  → returns an fd
   │  "Create a communication endpoint"               │
   ▼                                                   ▼
setsockopt(SO_REUSEADDR)                    (usually not needed)
   │  "Configure this endpoint"
   ▼
bind(fd, address)
   │  "Pin this endpoint to 0.0.0.0:3490"
   ▼
listen(fd, backlog)                         connect(fd, target_address)
   │  "Enter listening state and start queuing"        │  "Actively initiate the handshake"
   ▼                                                   ▼
accept(fd)  → returns conn_fd               (three-way handshake complete)
   │  "Take one fully established client from the queue"
   ▼                                                   ▼
recv(conn_fd) / send(conn_fd)  ◀──────────▶  send(fd) / recv(fd)
   │  "Send and receive data on the established connection"
   ▼                                                   ▼
close(conn_fd)                              close(fd)
```

UDP will be much easier.

Later, we will encounter I/O multiplexing and concurrency control:

- sys/select.h
- poll.h
- sys/epoll.h
- pthread.h

### 3.3 Simple server demo code

The following code is from Beej's demos:

- `src/show_ip.c`: learn what `getaddrinfo` does
- `src/bj_server.c`: a simple TCP server demo
- `src/bj_client.c`: a simple TCP client demo

Since these examples are written in `C` style, I rewrote them in `CPP` style:

- `src/show_ip.cc`
- `src/bj_server.cc`
- `src/bj_client.cc`

## 4. Echo server

An echo server sends every byte it receives back to the client unchanged. The implementation is in `src/echo_server.cc` and `src/echo_client.cc`; this section walks through how to write it from scratch.

### 4.1 Check available port

First, check that the port is free. This example uses port 2026:

```bash
ss -tuln | grep :2026

# alternative
netstat -tuln | grep :2026
```

`tuln` lists listening (`l`) TCP (`t`) and UDP (`u`) sockets with numeric (`n`) ports. If the command prints nothing, the port is available.

### 4.2 Code framework

Section [3.2](#32-important-system-call-apis-for-network-programming) gives the basic structure of both sides. This example uses TCP:

- Server: `getaddrinfo` → `socket` → `setsockopt` → `bind` → `listen` → `accept` → `fork` → `recv`/`send` → `close`
- Client: `getaddrinfo` → `socket` → `connect` → `send` → `recv` → `close`

### 4.3 Server: bind and listen

`main()` prepares one listening socket for the whole process run:

1. **Resolve the local address.** `getaddrinfo(nullptr, "2026", hints)` with `AI_PASSIVE` returns wildcard addresses suitable for `bind()`: IPv4, IPv6, or both.
2. **Try the candidates until one works.** For each result: `socket()` → `setsockopt(SO_REUSEADDR)` → `bind()` → `listen()`. `SO_REUSEADDR` lets a restarted server bind while old connections are still in `TIME_WAIT`. When `bind()` or `listen()` fails, `close()` the socket and try the next candidate; the first success wins.
3. **Reap children.** A `SIGCHLD` handler calls `waitpid(-1, nullptr, WNOHANG)` in a loop, so exited children are collected instead of staying as zombies. `SA_RESTART` resumes an interrupted `accept()`.
4. **Accept forever.** `accept()` blocks until a client completes the handshake and returns a new fd for that connection. Log the peer address with `inet_ntop()`, then `fork()`.

### 4.4 Server: fork and echo

One child serves one connection while the parent returns to `accept()`:

```cpp
const int conn_fd = accept(listen_fd, ...);
const pid_t pid = fork();
if (pid == 0) {          // child: serve this connection
  close(listen_fd);      // the child never accepts
  // recv -> send_all loop until recv() returns 0
  close(conn_fd);
  exit(0);               // end the child process, not just this block
}
close(conn_fd);          // parent keeps only the listening socket
```

The child echo loop sends back every chunk it reads:

```cpp
while (true) {
  const ssize_t n = recv(conn_fd, buffer.data(), buffer.size(), 0);
  if (n == 0) break;                  // client closed its write side
  if (n < 0) { if (errno == EINTR) continue; break; }
  if (!send_all(conn_fd, buffer.data(), static_cast<std::size_t>(n))) break;
}
```

### 4.5 Client: connect, send, receive

1. Require exactly one argument: the server host name. The port constant must match the server's.
2. `getaddrinfo(host, "2026", hints)` — without `AI_PASSIVE`, because the result is meant for `connect()`.
3. For each candidate: `socket()` → `connect()`. On failure, `close()` the socket, mark that no connection is open, and try the next address.
4. Read one non-empty line from stdin with `std::getline()`.
5. `send_all()` the line; it loops until every byte is written.
6. `recv()` in a loop until exactly the same number of bytes has arrived, because TCP may split the echo across several segments.
7. `close()` the socket.

### 4.6 Why so many `close()` and `exit()` calls

Each file descriptor has one owner per process, and every copy must be released:

- After `fork()`, both parent and child hold `conn_fd`; each closes its own copy. The connection is released only when both are gone.
- The child closes `listen_fd`: only the parent calls `accept()`, so the child must not keep a second reference to the listening socket.
- The fd from a failed `bind()`, `listen()`, or `connect()` is closed before the next attempt; otherwise each retry leaks one descriptor.
- The child uses `exit(0)`: falling through would return into `main`'s loop and make the child call `accept()` on a socket it does not own.
- The `SIGCHLD` handler collects the child's exit status; without it every connection leaves a zombie.
- Error paths close the socket before returning, so the descriptor is released immediately and ownership stays explicit.
- `std::cout.flush()` before `fork()` stops the child from flushing the parent's buffered output a second time.

### 4.7 Build, run, verify

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

Run the server in one terminal and the client in another:

```bash
# terminal A
./build/echo_server
# server: listening on port 2026, press Ctrl-C to stop
# server: connection from 127.0.0.1

# terminal B
./build/echo_client localhost
# Please enter message: hello
# client: received 'hello'
```

Checks:

- A message longer than 100 bytes returns unchanged; the loop handles several chunks.
- Two clients can run at the same time; each gets its own child.
- `ss -tlnp | grep 2026` shows exactly one listener in `LISTEN`.
- `ps --ppid $(pgrep -x echo_server) -o stat=` shows no `Z` states.
- With the server stopped, the client prints `Connection refused` and exits with status 2.
- `Ctrl-C` stops the server; process exit closes the listening socket.
