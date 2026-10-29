#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <array>
#include <iostream>
#include <memory>
#include <string_view>

// RAII: define a new deleter
struct AddrInfoDeleter {
  void operator()(addrinfo *p) const noexcept { ::freeaddrinfo(p); }
};
using AddrInfoPtr =
    std::unique_ptr<addrinfo,
                    AddrInfoDeleter>; // call new delete function in destruction

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cerr << "usage: showip hostname\n";
    return 1;
  }
  const std::string_view host = argv[1];

  addrinfo hints{};
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;

  addrinfo *raw = nullptr;
  if (const int rc = ::getaddrinfo(host.data(), nullptr, &hints, &raw);
      rc != 0) {
    std::cerr << "getaddrinfo: " << ::gai_strerror(rc) << '\n';
    return 2;
  }
  const std::unique_ptr<addrinfo, AddrInfoDeleter> res(raw);

  std::cout << "IP addresses for " << host << ":\n\n";

  for (addrinfo *p = res.get(); p != nullptr; p = p->ai_next) {
    const void *addr = nullptr;
    const char *version = nullptr;

    if (p->ai_family == AF_INET) {
      addr = &reinterpret_cast<sockaddr_in *>(p->ai_addr)->sin_addr;
      version = "IPv4";
    } else if (p->ai_family == AF_INET6) {
      addr = &reinterpret_cast<sockaddr_in6 *>(p->ai_addr)->sin6_addr;
      version = "IPv6";
    } else {
      continue;
    }

    std::array<char, INET6_ADDRSTRLEN> text{};
    if (::inet_ntop(p->ai_family, addr, text.data(), text.size()) == nullptr) {
      continue;
    }
    std::cout << "  " << version << ": " << text.data() << '\n';
  }
  return 0;
}
