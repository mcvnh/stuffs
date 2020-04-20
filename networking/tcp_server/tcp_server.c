#if defined(_WIN32)

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0600
#endif

#include <winsock2.h>
#include <ws2tcpip.h>

// Pragma tells the Microsoft Visual C compiler to link the program against the
// winsock library. If using MinGW, then #pragma is ignored, we have to tell
// the compiler to link ws2_32.lib on the command line using -lws2_32 option.
// Ex: gcc template.c -o template -lws2_32
#pragma comment(lib, "ws2_32.lib")

#define ISVALIDSOCKET(s) ((s) != INVALID_SOCKET)
#define CLOSESOCKET(s) closesocket(s)
#define GETSOCKETERRNO() (WSAGetLastError())

#else

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>

// SOCKET is a `typedef` for an `unsigned int` in winsock headers.
// It useful to either to use SOCKET on non-windows platforms.
#define SOCKET int

#define ISVALIDSOCKET(s) ((s) >= 0)
#define CLOSESOCKET(s) close(s)
#define GETSOCKETERRNO() (errno)

#endif

#include <stdio.h>
#include <ctype.h>
#include <string.h>

int main() {

#if defined(_WIN32)
  WSADATA d;
  if (WSAStartup(MAKEWORD(2, 2), &d)) {
    fprintf(stderr, "Failed to initialize.\n");
    return 1;
  }
#endif

  int result;
  struct addrinfo hints, *bind_address;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_INET;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  result = getaddrinfo(0, "8080", &hints, &bind_address);
  if (result != 0) {
    fprintf(stderr, "getaddrinfo() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  SOCKET sockfd = socket(
    bind_address->ai_family,
    bind_address->ai_socktype,
    bind_address->ai_protocol
  );
  if (!ISVALIDSOCKET(sockfd)) {
    fprintf(stderr, "socket() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  // binding
  result = bind(
    sockfd,
    bind_address->ai_addr,
    bind_address->ai_addrlen
  );
  if (result != 0) {
    fprintf(stderr, "bind() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }
  freeaddrinfo(bind_address);


  // listening
  result = listen(sockfd, 10);
  if (result < 0) {
    fprintf(stderr, "listen() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }

  fd_set master;
  FD_ZERO(&master);
  FD_SET(sockfd, &master);
  SOCKET max_socket = sockfd;


  printf("Waiting for connections...\n");
  while(1) {
    fd_set reads;
    reads = master;
    result = select(max_socket + 1, &reads, 0, 0, 0);
    if (result < 0) {
      fprintf(stderr, "select() failed. (%d)\n", GETSOCKETERRNO());
      return 1;
    }

    SOCKET i;
    for (i = 1; i <= max_socket; i++) {
      if (FD_ISSET(i, &reads)) {
        if (i == sockfd) {
          struct sockaddr_storage client_address;
          socklen_t client_len = sizeof client_address;
          SOCKET clientfd = accept(
            sockfd,
            (struct sockaddr *) &clientfd,
            &client_len
          );
          if (!ISVALIDSOCKET(clientfd)) {
            fprintf(stderr, "accept() failed. (%d)\n", GETSOCKETERRNO());
            return 1;
          }

          FD_SET(clientfd, &master);
          if (clientfd > max_socket) {
            max_socket = clientfd;
          }

          char address_buffer[100];
          result = getnameinfo(
            (struct sockaddr *) &client_address,
            client_len,
            address_buffer,
            sizeof address_buffer,
            0,
            0,
            NI_NUMERICHOST
          );
          printf("New connection from %s\n", address_buffer);
        } else {
          char read[1024];
          int bytes_received = recv(i, read, 1024, 0);
          if (bytes_received < 1) {
            FD_CLR(i, &master);
            CLOSESOCKET(i);
            continue;
          }

          SOCKET j;
          for (j = 1; j <= max_socket; j++) {
            if (FD_ISSET(j, &master)) {
              if (j == sockfd || j == i) continue;
              else {
                send(j, read, bytes_received, 0);
              }
            }
          }
        }
      }
    }
  }

  printf("Closing listening socket...\n");
  CLOSESOCKET(sockfd);


#if defined(_WIN32)
  WSACleanup();
#endif

  return 0;
}
