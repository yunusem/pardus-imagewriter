QT += qml quick widgets

CONFIG += c++11

QT_PLUGINS -= qdds qicns qjp2 qmng qtga qtiff qwbmp qwebp

SOURCES += main.cpp \
    helper.cpp \
    common.cpp \
    devicehandler.cpp \
    imagewriter.cpp \
    physicaldevice.cpp

HEADERS += \
    helper.h \
    usbdevicemonitor.h \
    platform.h \
    common.h \
    usbdevice.h \
    devicehandler.h \
    physicaldevice.h \
    imagewriter.h

win32 {
    SOURCES += platform_win.cpp \
        usbdevicemonitor_win.cpp
    HEADERS += usbdevicemonitor_win_p.h
    QMAKE_CXXFLAGS_RELEASE -= -Zc:strictStrings
}
linux {
    SOURCES += platform_lin.cpp \
        platform_lin_suprogram.cpp \
        signalhandler.cpp \
        usbdevicemonitor_lin.cpp
    HEADERS += usbdevicemonitor_lin_p.h \
        signalhandler.h \
        platform_lin_suprogram.h
}
macx {
    OBJECTIVE_SOURCES += platform_mac.mm \
        usbdevicemonitor_mac.mm
    HEADERS += usbdevicemonitor_mac_p.h
}

RESOURCES += qml.qrc images.qrc \
    translations.qrc

DEFINES += QT_DEPRECATED_WARNINGS

win32 {
        CONFIG -= embed_manifest_dll embed_manifest_exe
        msvc {
                LIBS += Ole32.lib OleAut32.lib
                QMAKE_CXXFLAGS -= -Zc:strictStrings
                QMAKE_CXXFLAGS_RELEASE -= -Zc:strictStrings
                QMAKE_CFLAGS -= -Zc:strictStrings
                QMAKE_CFLAGS_RELEASE -= -Zc:strictStrings
        }
        mingw {
                QMAKE_CXXFLAGS += -std=gnu++11
                LIBS += -lole32 -loleaut32 -luuid
        }
}
linux:gcc {
        LIBS += -ldl
        QMAKE_LFLAGS_RELEASE -= -Wl,-z,now       # Make sure weak symbols are not resolved on link-time
        QMAKE_LFLAGS_DEBUG -= -Wl,-z,now
        QMAKE_LFLAGS -= -Wl,-z,now
        GCCSTRVER = $$system(g++ -dumpversion)
        GCCVERSION = $$split(GCCSTRVER, .)
        GCCV_MJ = $$member(GCCVERSION, 0)
        GCCV_MN = $$member(GCCVERSION, 1)
        greaterThan(GCCV_MJ, 3) {
                lessThan(GCCV_MN, 7) {
                        QMAKE_CXXFLAGS += -std=gnu++0x
                }
                greaterThan(GCCV_MN, 6) {
                        QMAKE_CXXFLAGS += -std=gnu++11
                }
        }
        contains(QT_CONFIG, static) {
                # Static build is meant for releasing, clean up the binary
                QMAKE_LFLAGS += -s
        }
}
macx {
        QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.7
        QMAKE_CFLAGS = $$replace(QMAKE_CFLAGS, '-mmacosx-version-min=10.6', '-mmacosx-version-min=10.7')
        QMAKE_CXXFLAGS = $$replace(QMAKE_CXXFLAGS, '-mmacosx-version-min=10.6', '-mmacosx-version-min=10.7')
        QMAKE_LFLAGS = $$replace(QMAKE_LFLAGS, '-mmacosx-version-min=10.6', '-mmacosx-version-min=10.7')
        QMAKE_OBJECTIVE_CFLAGS = $$replace(QMAKE_OBJECTIVE_CFLAGS, '-mmacosx-version-min=10.6', '-mmacosx-version-min=10.7')

        QMAKE_CXXFLAGS += -std=c++0x -stdlib=libc++
        QMAKE_OBJECTIVE_CFLAGS += -std=c++0x -stdlib=libc++
        QMAKE_INCDIR += /System/Library/Frameworks/AppKit.framework/Headers /System/Library/Frameworks/Security.framework/Headers /System/Library/Frameworks/ServiceManagement.framework/Headers
        QMAKE_LFLAGS += -framework IOKit -framework Cocoa -framework Security
        # Clean up the binary after linking
        QMAKE_POST_LINK = strip -S -x $(TARGET)
}

TARGET = piw

