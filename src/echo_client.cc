/*
** echo_client.cc -- connect to the echo server, send one line, and print the
** bytes the server sends back.
*/
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <array>
#include <cerrno>
#include <cstdio>
#include <iostream>
#include <memory>
#include <string>
#include <string_view>

// The server and the client must agree on this port.
constexpr std::string_view kPort{"2026"};

// Size of one recv() chunk. The echo may arrive in several chunks even when the
// message was sent at once, so the client reads until it has the full echo.
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

// send() may accept fewer bytes than requested, so keep sending until the whole
// line is written. MSG_NOSIGNAL makes send() return EPIPE instead of raising
// SIGPIPE, which would terminate the client when the server has closed.
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

int main(int argc, char *argv[]) {
  // 1. Read the server host name from the command line.
  if (argc != 2) {
    std::cerr << "usage: " << argv[0] << " hostname\n";
    return 1;
  }
  const std::string_view host = argv[1];

  // 2. Resolve host:port. Without AI_PASSIVE, the result is meant for
  //    connect(), not bind().
  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;     // allow either IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP
  addrinfo *raw = nullptr;
  if (const int rc = ::getaddrinfo(host.data(), kPort.data(), &hints, &raw);
      rc != 0) {
    std::cerr << "getaddrinfo: " << ::gai_strerror(rc) << '\n';
    return 1;
  }
  const AddrInfoPtr server_info(raw);

  // 3. Try each resolved address until connect() succeeds. A host name can map
  //    to several addresses (for example IPv6 and IPv4), so a failure on one
  //    address only means "try the next".
  int sockfd = -1;
  for (const addrinfo *p = server_info.get(); p != nullptr; p = p->ai_next) {
    sockfd = ::socket(p->ai_family, p->ai_socktype, p->ai_protocol);
    if (sockfd == -1) {
      std::perror("client: socket");
      continue; // try the next address
    }

    // Print the address before connecting so a slow or unreachable target is
    // visible in the output.
    std::array<char, INET6_ADDRSTRLEN> text{};
    const char *addr = ::inet_ntop(p->ai_family, get_in_addr(p->ai_addr),
                                   text.data(), text.size());
    if (addr != nullptr) {
      std::cout << "client: attempting connection to " << addr << '\n';
    }

    // connect() starts the TCP three-way handshake with the server.
    if (::connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      std::perror("client: connect");
      ::close(sockfd); // this socket cannot be reused; release it
      sockfd = -1;     // remember that no connection is open
      continue;
    }

    if (addr != nullptr) {
      std::cout << "client: connected to " << addr << '\n';
    }
    break; // connected; no need to try further addresses
  }

  if (sockfd == -1) {
    std::cerr << "client: could not connect to " << host << '\n';
    return 2;
  }

  // 4. Read one line from stdin. std::getline() drops the trailing newline, so
  //    the message is exactly what the user typed.
  std::cout << "Please enter message: ";
  std::string message;
  if (!std::getline(std::cin, message)) {
    std::cerr << "client: failed to read a message\n";
    ::close(sockfd); // release the connection before returning
    return 1;
  }
  if (message.empty()) {
    std::cerr << "client: empty message; nothing to send\n";
    ::close(sockfd); // release the connection before returning
    return 1;
  }

  // 5. Send the whole line. send_all() loops over partial writes.
  if (!send_all(sockfd, message.data(), message.size())) {
    std::perror("client: send");
    ::close(sockfd); // release the connection before returning
    return 1;
  }

  // 6. Read until every sent byte comes back. The server echoes each chunk, so
  //    the echo may be split over several recv() calls.
  std::string echoed;
  std::array<char, kChunkSize> buffer{};
  while (echoed.size() < message.size()) {
    const ssize_t n = ::recv(sockfd, buffer.data(), buffer.size(), 0);
    if (n == -1) {
      if (errno == EINTR) {
        continue; // a signal interrupted recv(); retry
      }
      std::perror("client: recv");
      ::close(sockfd); // release the connection before returning
      return 1;
    }
    if (n == 0) {
      std::cerr << "client: server closed before the whole echo arrived\n";
      ::close(sockfd); // release the connection before returning
      return 1;
    }
    echoed.append(buffer.data(), static_cast<std::size_t>(n));
  }

  std::cout << "client: received '" << echoed << "'\n";

  // 7. Close the connection. The process would close it at exit anyway, but an
  //    explicit close documents who owns the fd and releases it immediately.
  ::close(sockfd);
  return 0;
}
