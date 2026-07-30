QT += core network

TEMPLATE = app
TARGET = RubbageChatProtocolSmokeTest
CONFIG += console c++17 release
CONFIG -= app_bundle debug_and_release debug

PROJECT_ROOT = $$clean_path($$PWD/../..)

SOURCES += \
    ProtocolSmokeTest.cpp \
    $$PROJECT_ROOT/libs/protocol/ChatProtocol.cpp

HEADERS += $$PROJECT_ROOT/libs/protocol/ChatProtocol.h
INCLUDEPATH += $$PROJECT_ROOT/libs/protocol
