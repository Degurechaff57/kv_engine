/*
** showip.c
**
** show IP addresses for a host given on the command line
*/

#include <arpa/inet.h> // inet_ntop
#include <netdb.h> // getaddrinfo, freeaddrinfo, gai_strerror, struct addrinfo
#include <netinet/in.h> // struct sockaddr_in, sockaddr_in6, INET6_ADDRSTRLEN
#include <stdio.h>
#include <string.h>     // memset
#include <sys/socket.h> // AF_INET, AF_INET6, SOCK_STREAM
#include <sys/types.h>

int main(int argc, char *argv[]) {
  struct addrinfo hints, *res, *p;
  int status;
  char ipstr[INET6_ADDRSTRLEN];

  if (argc != 2) {
    fprintf(stderr, "usage: showip hostname\n");
    return 1;
  }

  memset(&hints, 0,
         sizeof hints);        // clear dirty data of struct addrinfo named hits
  hints.ai_family = AF_UNSPEC; // Either IPv4 (AF_INET) or IPv6 (AF_INET6)
  hints.ai_socktype = SOCK_STREAM; // TCP

  // int getaddrinfo(const char *node,   // e.g. "www.example.com" or IP
  //               const char *service,  // e.g. "http" (from etc/services) or
  //               port number const struct addrinfo *hints, struct addrinfo
  //               **res);
  if ((status = getaddrinfo(argv[1], NULL, &hints, &res)) != 0) {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
    return 2;
  }

  printf("IP addresses for %s:\n\n", argv[1]);

  for (p = res; p != NULL; p = p->ai_next) {
    void *addr;
    char *ipver;
    struct sockaddr_in *ipv4;
    struct sockaddr_in6 *ipv6;

    // get the pointer to the address itself,
    // different fields in IPv4 and IPv6:
    if (p->ai_family == AF_INET) { // IPv4
      ipv4 = (struct sockaddr_in *)p->ai_addr;
      addr = &(ipv4->sin_addr);
      ipver = "IPv4";
    } else { // IPv6
      ipv6 = (struct sockaddr_in6 *)p->ai_addr;
      addr = &(ipv6->sin6_addr);
      ipver = "IPv6";
    }

    // convert the IP to a string and print it:
    inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
    printf("  %s: %s\n", ipver, ipstr);
  }

  freeaddrinfo(res); // free the linked list

  return 0;
}
