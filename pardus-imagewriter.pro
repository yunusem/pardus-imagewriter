QT += qml quick widgets svg

CONFIG += c++11

QT_PLUGINS -= qdds qicns qjp2 qmng qtga qtiff qwbmp qwebp

TARGET = piw

SOURCES += src/main.cpp \
    src/helper.cpp \
    src/common.cpp \
    src/devicehandler.cpp \
    src/imagewriter.cpp \
    src/physicaldevice.cpp

HEADERS += \
    src/helper.h \
    src/usbdevicemonitor.h \
    src/platform.h \
    src/common.h \
    src/usbdevice.h \
    src/devicehandler.h \
    src/physicaldevice.h \
    src/imagewriter.h

win32 {
    RC_FILE = piw.rc
    SOURCES += src/platform_win.cpp \
        src/usbdevicemonitor_win.cpp
    HEADERS += src/usbdevicemonitor_win_p.h
    QMAKE_CXXFLAGS_RELEASE -= -Zc:strictStrings
}
linux {
    SOURCES += src/platform_lin.cpp \
        src/signalhandler.cpp \
        src/usbdevicemonitor_lin.cpp
    HEADERS += src/usbdevicemonitor_lin_p.h \
        src/signalhandler.h

    target.path = /usr/bin/

    desktop_file.files = pardus-imagewriter.desktop
    desktop_file.path = /usr/share/applications/

    icon.files = images/icon.svg
    icon.commands = mkdir -p /usr/share/pardus/pardus-imagewriter
    icon.path = /usr/share/pardus/pardus-imagewriter

    policy.files = tr.org.pardus.pkexec.pardus-imagewriter.policy
    policy.commands = mkdir -p /usr/share/polkit-1/actions
    policy.path = /usr/share/polkit-1/actions

    INSTALLS += target desktop_file icon policy

}
macx {
    OBJECTIVE_SOURCES += src/platform_mac.mm \
        src/usbdevicemonitor_mac.mm
    HEADERS += src/usbdevicemonitor_mac_p.h
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

