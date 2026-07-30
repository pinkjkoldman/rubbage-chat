QT += core gui network qml quick quickcontrols2 concurrent

TEMPLATE = app
TARGET = RubbageChatServer
CONFIG += c++17 release
CONFIG -= debug_and_release debug

SERVER_ROOT = $$PWD
PROJECT_ROOT = $$clean_path($$PWD/../..)
MONGO_CXX = $$clean_path($$PROJECT_ROOT/third_party/mongo-driver)
MONGO_C = $$clean_path($$PROJECT_ROOT/third_party/mongo-c-driver-install)

INCLUDEPATH += \
    $$SERVER_ROOT/network \
    $$SERVER_ROOT/storage \
    $$PROJECT_ROOT/libs/protocol \
    $$MONGO_CXX/include \
    $$MONGO_CXX/include/bsoncxx/v_noabi \
    $$MONGO_CXX/include/mongocxx/v_noabi \
    $$MONGO_C/include/bson-2.3.3 \
    $$MONGO_C/include/mongoc-2.3.3

DEFINES += BSONCXX_STATIC MONGOCXX_STATIC BSON_STATIC MONGOC_STATIC

SOURCES += \
    main.cpp \
    application/ChatCommandService.cpp \
    network/ChatServer.cpp \
    storage/MongoChatStore.cpp \
    $$PROJECT_ROOT/libs/protocol/ChatProtocol.cpp

HEADERS += \
    application/ChatCommandService.h \
    network/ChatServer.h \
    storage/MongoChatStore.h \
    $$PROJECT_ROOT/libs/protocol/ChatProtocol.h

RESOURCES += resources.qrc

LIBS += \
    -L$$MONGO_CXX/lib \
    -lmongocxx1-static \
    -lbsoncxx1-static \
    $$MONGO_C/lib/libmongoc2.a \
    $$MONGO_C/lib/libbson2.a \
    -lsecur32 -lcrypt32 -lbcrypt -lncrypt -lws2_32

win32 {
    CONFIG += windows
}
