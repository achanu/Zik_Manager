TEMPLATE = app

TARGET = zik-manager

ICON = ../icons/harbour-zik-manager.icns

QT += core qml quick bluetooth svg gui

unix:!android {
    QT += widgets dbus
}

android {
    ANDROID_ABIS = arm64-v8a
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/../android
    QML_IMPORT_PATH += $[QT_INSTALL_QML]
}

SOURCES += src/main.cpp

unix:!android {
    SOURCES += src/systraymanager.cpp
    HEADERS += src/systraymanager.h
}

RESOURCES += \
    ../qml/common_ui.qrc \
    qml/ui.qrc
    
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

CONFIG += c++17

# libParrotZik config
win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../libParrotZik/release/ -lParrotZik
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../libParrotZik/debug/ -lParrotZik
else:unix: LIBS += -L$$OUT_PWD/../libParrotZik/ -lParrotZik

INCLUDEPATH += $$PWD/../libParrotZik/include
DEPENDPATH += $$PWD/../libParrotZik

# debug config
CONFIG(debug, debug|release) {
    message(debug build)
    DEFINES += DEBUG
}
else {
    message(release build)
    DEFINES += QT_NO_DEBUG_OUTPUT
}
