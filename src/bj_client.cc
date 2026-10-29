/*
** bj_client.cc -- a stream socket client demo, rewritten in C++ style
*/

#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <array>
#include <cstdio>
#include <iostream>
#include <memory>
#include <string_view>

// the port client will be connecting to
constexpr std::string_view kPort{"3490"};

// max number of bytes we can get at once
constexpr std::size_t kMaxDataSize = 100;

// RAII: define a new deleter
struct AddrInfoDeleter {
  void operator()(addrinfo *p) const noexcept { ::freeaddrinfo(p); }
};
using AddrInfoPtr =
    std::unique_ptr<addrinfo,
                    AddrInfoDeleter>; // call new delete function in destruction

// get sockaddr, IPv4 or IPv6:
const void *get_in_addr(const sockaddr *sa) {
  if (sa->sa_family == AF_INET) {
    return &reinterpret_cast<const sockaddr_in *>(sa)->sin_addr;
  }
  return &reinterpret_cast<const sockaddr_in6 *>(sa)->sin6_addr;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cerr << "usage: client hostname\n";
    return 1;
  }
  const std::string_view host = argv[1];

  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  addrinfo *raw = nullptr;
  if (const int rc = ::getaddrinfo(host.data(), kPort.data(), &hints, &raw);
      rc != 0) {
    std::cerr << "getaddrinfo: " << ::gai_strerror(rc) << '\n';
    return 1;
  }
  const AddrInfoPtr servinfo(raw);

  // loop through all the results and connect to the first we can
  int sockfd = -1;
  for (const addrinfo *p = servinfo.get(); p != nullptr; p = p->ai_next) {
    sockfd = ::socket(p->ai_family, p->ai_socktype, p->ai_protocol);
    if (sockfd == -1) {
      std::perror("client: socket");
      continue;
    }

    std::array<char, INET6_ADDRSTRLEN> text{};
    const char *addr = ::inet_ntop(p->ai_family, get_in_addr(p->ai_addr),
                                   text.data(), text.size());
    if (addr != nullptr) {
      std::cout << "client: attempting connection to " << addr << '\n';
    }

    if (::connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      std::perror("client: connect");
      ::close(sockfd);
      sockfd = -1;
      continue;
    }

    if (addr != nullptr) {
      std::cout << "client: connected to " << addr << '\n';
    }
    break;
  }

  if (sockfd == -1) {
    std::cerr << "client: failed to connect\n";
    return 2;
  }

  std::array<char, kMaxDataSize> buf{};
  const ssize_t numbytes = ::recv(sockfd, buf.data(), buf.size(), 0);
  if (numbytes == -1) {
    std::perror("recv");
    ::close(sockfd);
    return 1;
  }

  const std::string_view received(
      buf.data(), static_cast<std::size_t>(numbytes));
  std::cout << "client: received '" << received << "'\n";

  ::close(sockfd);

  return 0;
}
