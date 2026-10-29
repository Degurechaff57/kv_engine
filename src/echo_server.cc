/*
** echo_server.cc -- a TCP echo server: every byte a client sends is sent back.
**
** The server resolves a wildcard local address, binds and listens, then loops
** on accept(). Each accepted connection is handled by a forked child, so a
** slow client cannot block the accept() loop.
*/
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <array>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string_view>

// Port the server listens on. The client must use the same value.
constexpr std::string_view kPort{"2026"};

// Maximum number of connections that have completed the TCP handshake but
// have not been accepted yet.
constexpr int kBacklog = 10;

// Size of one recv()/send() chunk. TCP is a byte stream: one recv() may return
// any positive number of bytes, so the echo loop handles one chunk at a time.
constexpr std::size_t kChunkSize = 100;

// RAII: free the addrinfo list when this pointer goes out of scope, so every
// return path releases it without a separate freeaddrinfo() call.
struct AddrInfoDeleter {
  void operator()(addrinfo *p) const noexcept { ::freeaddrinfo(p); }
};
using AddrInfoPtr = std::unique_ptr<addrinfo, AddrInfoDeleter>;

// Return a pointer to the raw address inside a generic sockaddr. inet_ntop()
// needs that pointer, and IPv4 and IPv6 store it at different offsets, so the
// address family selects the right cast.
const void *get_in_addr(const sockaddr *sa) {
  if (sa->sa_family == AF_INET) {
    return &reinterpret_cast<const sockaddr_in *>(sa)->sin_addr;
  }
  return &reinterpret_cast<const sockaddr_in6 *>(sa)->sin6_addr;
}

// SIGCHLD handler: reap every child that has exited. A forked child exits after
// serving one connection. Without waitpid(), each one stays in the process
// table as a zombie until the parent collects it. The loop repeats because
// several children may have exited before the handler runs.
void reap_children(int) {
  // A signal handler may interrupt code that relies on errno, so preserve the
  // current value across the waitpid() calls and restore it before returning.
  const int saved_errno = errno;
  while (::waitpid(-1, nullptr, WNOHANG) > 0) {
  }
  errno = saved_errno;
}

// send() may accept fewer bytes than requested, so keep sending until the whole
// chunk is written. MSG_NOSIGNAL makes send() return EPIPE instead of raising
// SIGPIPE, which would terminate the process when the peer has already closed.
bool send_all(int fd, const char *data, std::size_t length) {
  std::size_t sent = 0;
  while (sent < length) {
    const ssize_t n = ::send(fd, data + sent, length - sent, MSG_NOSIGNAL);
    if (n > 0) {
      sent += static_cast<std::size_t>(n);
      continue;
    }
    if (n == -1 && errno == EINTR) {
      continue; // a signal interrupted send(); retry the remaining bytes
    }
    return false;
  }
  return true;
}

int main() {
  // 1. Resolve the local address to bind. With AI_PASSIVE and a null node,
  //    getaddrinfo() returns wildcard addresses that bind() can use.
  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;     // allow either IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP: ordered, reliable byte stream
  hints.ai_flags = AI_PASSIVE;     // produce wildcard addresses for bind()

  addrinfo *raw = nullptr;
  if (const int rc = ::getaddrinfo(nullptr, kPort.data(), &hints, &raw);
      rc != 0) {
    std::cerr << "getaddrinfo: " << ::gai_strerror(rc) << '\n';
    return 1;
  }
  const AddrInfoPtr server_info(raw);

  // 2. Try the candidates until one socket binds and listens. The first
  //    candidate may be an address family this machine cannot use, so a
  //    failure only means "try the next candidate", not "give up".
  int listen_fd = -1;
  for (const addrinfo *p = server_info.get(); p != nullptr; p = p->ai_next) {
    listen_fd = ::socket(p->ai_family, p->ai_socktype, p->ai_protocol);
    if (listen_fd == -1) {
      std::perror("server: socket");
      continue; // try the next candidate
    }

    // SO_REUSEADDR lets a restarted server bind while old connections still
    // sit in TIME_WAIT; without it a restart can fail with EADDRINUSE.
    const int yes = 1;
    if (::setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof yes) ==
        -1) {
      std::perror("server: setsockopt");
      ::close(listen_fd); // release the fd before returning
      return 1;
    }

    // bind() fixes the local address of this socket. If the candidate fails,
    // close the fd (otherwise it leaks) and try the next one.
    if (::bind(listen_fd, p->ai_addr, p->ai_addrlen) == -1) {
      std::perror("server: bind");
      ::close(listen_fd);
      listen_fd = -1;
      continue;
    }

    // listen() marks the socket passive and lets the kernel queue incoming
    // connections. Only accept() can then return usable connection sockets.
    if (::listen(listen_fd, kBacklog) == -1) {
      std::perror("server: listen");
      ::close(listen_fd); // free this candidate before trying the next
      listen_fd = -1;
      continue;
    }

    break; // the first candidate that works is enough
  }

  if (listen_fd == -1) {
    std::cerr << "server: cannot bind and listen on port " << kPort << '\n';
    return 1;
  }

  // 3. Reap children as they exit, otherwise every connection leaves a zombie.
  //    SA_RESTART makes the interrupted accept() resume automatically.
  struct sigaction action{}; // the function sigaction() hides the struct name
  action.sa_handler = reap_children;
  ::sigemptyset(&action.sa_mask);
  action.sa_flags = SA_RESTART;
  if (::sigaction(SIGCHLD, &action, nullptr) == -1) {
    std::perror("server: sigaction");
    ::close(listen_fd); // release the listener before returning
    return 1;
  }

  std::cout << "server: listening on port " << kPort
            << ", press Ctrl-C to stop\n";
  std::cout.flush(); // show the startup line even if stdout is redirected

  // 4. Serve connections forever. accept() blocks until a client completes the
  //    TCP handshake and returns a new fd for that connection.
  while (true) {
    sockaddr_storage peer_addr{};
    socklen_t peer_len = sizeof peer_addr;
    const int conn_fd = ::accept(
        listen_fd, reinterpret_cast<sockaddr *>(&peer_addr), &peer_len);
    if (conn_fd == -1) {
      if (errno == EINTR) {
        continue; // a signal interrupted accept(); retry
      }
      std::perror("server: accept");
      continue; // one failed accept() must not stop the server
    }

    // Log the peer address. inet_ntop() needs the address field, which
    // get_in_addr() extracts from the generic sockaddr.
    const sockaddr *peer = reinterpret_cast<const sockaddr *>(&peer_addr);
    std::array<char, INET6_ADDRSTRLEN> peer_text{};
    if (const char *peer_name = ::inet_ntop(
            peer_addr.ss_family, get_in_addr(peer), peer_text.data(),
            peer_text.size());
        peer_name != nullptr) {
      std::cout << "server: connection from " << peer_name << '\n';
    }
    // Flush before fork(): the child inherits this buffer, and the child's
    // exit would otherwise flush the same text a second time.
    std::cout.flush();

    // 5. Fork one child per connection so the parent can accept the next
    //    client immediately.
    const pid_t pid = ::fork();
    if (pid == -1) {
      std::perror("server: fork");
      ::close(conn_fd); // the parent cannot serve this one; release it
      continue;
    }

    if (pid == 0) {
      // Child process: serve this connection, then terminate.
      // The child never accepts, so it closes its copy of the listener. That
      // frees the descriptor and leaves the parent as the only owner.
      ::close(listen_fd);

      // Echo loop: send every received chunk back unchanged. recv() returns 0
      // when the client shuts down its write side, which ends the loop.
      std::array<char, kChunkSize> buffer{};
      while (true) {
        const ssize_t n = ::recv(conn_fd, buffer.data(), buffer.size(), 0);
        if (n == -1) {
          if (errno == EINTR) {
            continue; // a signal interrupted recv(); retry
          }
          std::perror("server: recv");
          break;
        }
        if (n == 0) {
          break; // orderly shutdown from the client: no more data
        }
        if (!send_all(conn_fd, buffer.data(), static_cast<std::size_t>(n))) {
          std::perror("server: send");
          break;
        }
      }

      // Close the connection this child owns. exit(0) ends only this forked
      // copy of the server: returning into main's loop would make the child
      // call accept() on a socket it does not own.
      ::close(conn_fd);
      std::exit(0);
    }

    // Parent process: the child owns conn_fd now. Close the parent's copy too;
    // a socket is released only after every process closes its copy.
    ::close(conn_fd);
  }

  // Unreachable: the accept loop ends only when the process is killed.
  return 0;
}
