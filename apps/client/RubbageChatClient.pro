QT += core gui network qml quick quickcontrols2

TEMPLATE = app
TARGET = RubbageChat
CONFIG += c++17 release
CONFIG -= debug_and_release debug

CLIENT_ROOT = $$PWD
PROJECT_ROOT = $$clean_path($$PWD/../..)

SOURCES += \
    main.cpp \
    application/ChatController.cpp \
    network/EndpointDiscovery.cpp \
    storage/ReliableOutbox.cpp \
    $$PROJECT_ROOT/libs/protocol/ChatProtocol.cpp

HEADERS += \
    application/ChatController.h \
    network/EndpointDiscovery.h \
    storage/ReliableOutbox.h \
    $$PROJECT_ROOT/libs/protocol/ChatProtocol.h

INCLUDEPATH += $$PROJECT_ROOT/libs/protocol

RESOURCES += resources.qrc
RC_ICONS = assets/RubbageChat.ico

win32 {
    CONFIG += windows
}
