#if defined(_WIN32)

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0600
#endif

#include <winsock2.h>
#include <ws2tcpip.h>
#include <conio.h>

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

int main(int argc, char *argv[]) {

#if defined(_WIN32)
  WSADATA d;
  if (WSAStartup(MAKEWORD(2, 2), &d)) {
    fprintf(stderr, "Failed to initialize.\n");
    return 1;
  }
#endif

  if (argc < 3) {
    fprintf(stderr, "usage: tcp_client hostname port\n");
    return 1;
  }

  /* Configuring remote address... */
  int result;
  struct addrinfo hints, *peer_address;
  memset(&hints, 0, sizeof hints);
  hints.ai_socktype = SOCK_STREAM;
  result = getaddrinfo(argv[1], argv[2], &hints, &peer_address);
  if (result != 0) {
    fprintf(stderr, "getaddrinfo() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  char address_buffer[100];
  char service_buffer[100];
  result = getnameinfo(
    peer_address->ai_addr,
    peer_address->ai_addrlen,
    address_buffer,
    sizeof address_buffer,
    service_buffer,
    sizeof service_buffer,
    NI_NUMERICHOST
  );
  if (result != 0) {
    fprintf(stderr, "getnameinfo() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }

  printf("Remote address is: %s %s\n", address_buffer, service_buffer);


  /* Creating socket... */
  SOCKET socket_peer = socket(
    peer_address->ai_family,
    peer_address->ai_socktype,
    peer_address->ai_protocol
  );
  if (!ISVALIDSOCKET(socket_peer)) {
    fprintf(stderr, "socket() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }


  result = connect(
    socket_peer,
    peer_address->ai_addr,
    peer_address->ai_addrlen
  );
  if (result != 0) {
    fprintf(stderr, "connect() failed. (%d)\n", GETSOCKETERRNO());
    return 1;
  }
  freeaddrinfo(peer_address);

  printf("Connected.\n");
  printf("To send data, enter text followed by enter.\n");

  while(1) {
    fd_set reads;
    FD_ZERO(&reads);
    FD_SET(socket_peer, &reads);
#if !defined(_WIN32 )
    FD_SET(0, &reads);
#endif

    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 100000;

    result = select(socket_peer + 1, &reads, 0, 0, &timeout);
    if (result < 0) {
      fprintf(stderr, "select() failed. (%d)\n", GETSOCKETERRNO());
      return 1;
    }

    if (FD_ISSET(socket_peer, &reads)) {
      char read[4096];
      int bytes_received = recv(socket_peer, read, 4096, 0);
      if (bytes_received < 1) {
        printf("Connection closed by peer.\n");
        break;
      }

      printf("Received (%d bytes): %.*s", bytes_received, bytes_received, read);
    }

#if defined(_WIN32)
    if (_kbhit()) {
#else
    if (FD_ISSET(0, &reads)) {
#endif
      char read[4096];
      if (!fgets(read, 4096, stdin)) break;
      printf("Sending: %s", read);
      int bytes_sent = send(socket_peer, read, strlen(read), 0);
      printf("Sent %d bytes.\n", bytes_sent);
    }
  }

  printf("Closing socket...\n");
  CLOSESOCKET(socket_peer);

#if defined(_WIN32)
  WSACleanup();
#endif

  return 0;
}
