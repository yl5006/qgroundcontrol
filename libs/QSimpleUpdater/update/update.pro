QT += core

TARGET = update

CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp
#CONFIG  += console release
include ($$PWD/../QSimpleUpdater.pri)

