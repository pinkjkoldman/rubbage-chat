# MongoDB driver artifacts

`mongo-driver` contains MongoDB C++ Driver 4.4.1 headers and MinGW static
libraries. `mongo-c-driver-install` contains MongoDB C Driver 2.3.3 and libbson
headers/static libraries. They were built in Release mode with the same MinGW
13.1 toolchain used by Qt 6.11.0.

The server qmake project links these archives statically, so no MongoDB driver
DLL is required in `deploy`. License and third-party notice files are retained
under each installed artifact directory.
