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
#include <string.h>
#include <time.h>

int main() {

#if defined(_WIN32)
  WSADATA d;
  if (WSAStartup(MAKEWORD(2, 2), &d)) {
    fprintf(stderr, "Failed to initialize.\n");
    return 1;
  }
#endif

  struct addrinfo hints, *bind_address;
  SOCKET sockfd;
  int result;

  printf(" 1. Figure out the local address that the program should bind to.\n");
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_flags = AI_PASSIVE;

  result = getaddrinfo(0, "8080", &hints, &bind_address);
  if (result != 0) {
    fprintf(stderr, "server: getaddrinfo failed.");
    fprintf(stderr, "  %s\n", gai_strerror(result));
    return 1;
  }


  printf(" 2. Create the socket.\n");
  sockfd = socket(
    bind_address->ai_family,
    bind_address->ai_socktype,
    bind_address->ai_protocol
  );

  if (!ISVALIDSOCKET(sockfd)) {
    fprintf(stderr, "server: socket() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  printf(" 3. Binding socket to local address.\n");
  result = bind(
    sockfd,
    bind_address->ai_addr,
    bind_address->ai_addrlen
  );
  if (result != 0) {
    fprintf(stderr, "server: bind() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }

  // we don't need bind_address anymore
  freeaddrinfo(bind_address);


  printf(" 4. Listening.\n");
  result = listen(sockfd, 10);
  if (result < 0) {
    fprintf(stderr, "server: listen() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  printf(" 5. Waiting for connection.\n");
  struct sockaddr_storage client_address;
  socklen_t client_length = sizeof client_address;
  SOCKET clientfd = accept(sockfd, (struct sockaddr*) &client_address, &client_length);

  if (!ISVALIDSOCKET(clientfd)) {
    fprintf(stderr, "server: accept() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  printf(" 6. Print client address to console.\n");
  char address_buffer[100];
  result = getnameinfo(
    (struct sockaddr *)&client_address,
    client_length,
    address_buffer,
    sizeof address_buffer,
    0, // serv
    0, // servlen
    NI_NUMERICHOST
  );

  if (result != 0) {
    fprintf(stderr, "server: could not resolve hostname");
    return 1;
  }
  printf("     Client IP Address: %s\n", address_buffer);


  printf(" 7. Reading request.\n");
  char request[1024];
  int bytes_received = recv(clientfd, request, 1024, 0);
  if (bytes_received == -1) {
    fprintf(stderr, "server: recv() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }
  printf("      Received %d bytes.\n", bytes_received);
  // printf("      %.*s", bytes_received, request);


  printf(" 8. Sending response.\n");
  const char *response =
    "HTTP/1.1 200 OK\r\n"
    "Connection: close\r\n"
    "Content-Type: text/plain\r\n\r\n"
    "Local time is: ";

  int bytes_sent = send(clientfd, response, strlen(response), 0);
  if (bytes_sent == -1) {
    fprintf(stderr, "server: send(1) failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }

  printf("      Sent %d of %d bytes.\n", bytes_sent, (int)strlen(response));

  time_t timer;
  time(&timer);
  char *time_msg = ctime(&timer);
  bytes_sent = send(clientfd, time_msg, strlen(time_msg), 0);
  if (bytes_sent == -1) {
    fprintf(stderr, "server: send(2) failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }
  printf("      Sent %d of %d bytes.\n", bytes_sent, (int)strlen(response));

  printf(" 9. Closing client.\n");
  CLOSESOCKET(clientfd);


  printf("10. Closing server.\n");
  CLOSESOCKET(sockfd);

#if defined(_WIN32)
  WSACleanup();
#endif

  return 0;
}
