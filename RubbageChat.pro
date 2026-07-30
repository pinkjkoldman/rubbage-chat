TEMPLATE = subdirs
CONFIG += ordered

SUBDIRS += client server protocol_test

client.file = apps/client/RubbageChatClient.pro
server.file = apps/server/RubbageChatServer.pro
protocol_test.file = tests/protocol/ProtocolSmokeTest.pro

server.depends = client
protocol_test.depends = server
