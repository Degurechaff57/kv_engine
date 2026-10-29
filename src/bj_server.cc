/*
** bj_server.cc -- a stream socket server demo, rewritten in C++ style
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

// the port users will be connecting to
constexpr std::string_view kPort{"3490"};

// how many pending connections queue will hold
constexpr int kBacklog = 10;

// max number of bytes we can get at once
constexpr std::size_t kMaxDataSize = 100;

constexpr std::string_view kGreeting{"Hello, world!"};

// RAII: define a new deleter
struct AddrInfoDeleter {
  void operator()(addrinfo *p) const noexcept { ::freeaddrinfo(p); }
};
using AddrInfoPtr =
    std::unique_ptr<addrinfo,
                    AddrInfoDeleter>; // call new delete function in destruction

void sigchld_handler(int) {
  // waitpid() might overwrite errno, so we save and restore it:
  const int saved_errno = errno;

  // -1 means any child process will be collected
  while (::waitpid(-1, nullptr, WNOHANG) > 0) {
  }

  errno = saved_errno;
}

// get sockaddr, IPv4 or IPv6:
const void *get_in_addr(const sockaddr *sa) {
  if (sa->sa_family == AF_INET) {
    return &reinterpret_cast<const sockaddr_in *>(sa)->sin_addr;
  }
  return &reinterpret_cast<const sockaddr_in6 *>(sa)->sin6_addr;
}

int main() {
  addrinfo hints{};
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE; // use my IP

  addrinfo *raw = nullptr;
  if (const int rc = ::getaddrinfo(nullptr, kPort.data(), &hints, &raw);
      rc != 0) {
    std::cerr << "getaddrinfo: " << ::gai_strerror(rc) << '\n';
    return 1;
  }
  const AddrInfoPtr servinfo(raw);

  // loop through all the results and bind to the first we can
  int sockfd = -1;
  bool bound = false;
  for (const addrinfo *p = servinfo.get(); p != nullptr; p = p->ai_next) {
    sockfd = ::socket(p->ai_family, p->ai_socktype, p->ai_protocol);
    if (sockfd == -1) {
      std::perror("server: socket");
      continue;
    }

    const int yes = 1;
    if (::setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof yes) ==
        -1) {
      std::perror("setsockopt");
      return 1;
    }

    if (::bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      ::close(sockfd);
      std::perror("server: bind");
      continue;
    }

    bound = true;
    break;
  }

  if (!bound) {
    std::cerr << "server: failed to bind\n";
    return 1;
  }

  if (::listen(sockfd, kBacklog) == -1) {
    std::perror("listen");
    return 1;
  }

  struct sigaction sa{}; // the function sigaction() hides the struct name
  sa.sa_handler = sigchld_handler; // reap all dead processes
  ::sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  if (::sigaction(SIGCHLD, &sa, nullptr) == -1) {
    std::perror("sigaction");
    return 1;
  }

  std::cout << "server: waiting for connections...\n";

  while (true) {                   // main accept() loop
    sockaddr_storage their_addr{}; // connector's address info
    socklen_t sin_size = sizeof their_addr;
    const int new_fd =
        ::accept(sockfd, reinterpret_cast<sockaddr *>(&their_addr), &sin_size);
    if (new_fd == -1) {
      std::perror("accept");
      continue;
    }

    const sockaddr *peer = reinterpret_cast<const sockaddr *>(&their_addr);
    std::array<char, INET6_ADDRSTRLEN> text{};
    const char *addr = ::inet_ntop(their_addr.ss_family, get_in_addr(peer),
                                   text.data(), text.size());
    if (addr != nullptr) {
      std::cout << "server: got connection from " << addr << '\n';
    }

    const pid_t pid = ::fork();
    if (pid == -1) {
      std::perror("fork");
      ::close(new_fd);
      continue;
    }

    if (pid == 0) {    // this is the child process
      ::close(sockfd); // child doesn't need the listener
      if (::send(new_fd, kGreeting.data(), kGreeting.size(), 0) == -1) {
        std::perror("send");
      }
      ::close(new_fd);
      std::exit(0);
    }
    ::close(new_fd); // parent doesn't need this
  }

  return 0;
}
