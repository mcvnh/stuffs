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

int main() {

#if defined(_WIN32)
  WSADATA d;
  if (WSAStartup(MAKEWORD(2, 2), &d)) {
    fprintf(stderr, "Failed to initialize.\n");
    return 1;
  }
#endif

  printf("Ready to use socket API.\n");

#if defined(_WIN32)
  WSACleanup();
#endif

  return 0;
}
