# Pardus Image Writer

Simple Qt cpp backend, qml frontend disk image writing application.

## Screen Shots

### On Linux (Pardus 17.1 GNU/Linux)

![p1](/screenshots/piw_pardus-1.png) ![p2](/screenshots/piw_pardus-2.png)

![p3](/screenshots/piw_pardus-3.png) ![p4](/screenshots/piw_pardus-4.png)

![p5](/screenshots/piw_pardus-5.png) ![p6](/screenshots/piw_pardus-6.png)

### On Windows (10 Home)

If you need a standalone `piw.exe` tested on Windows 10,
[here](https://www.pardus.org.tr/pardus-usb-olusturma/) it is. Guess the
install link if you are not a Turkish speaker then follow the instruction
screenshots to get your ISO file burnt into your USB stick.

![piw_windows](/screenshots/piw_windows.jpg)

### On MacOS (High Sierra)

![piw_macOS](/screenshots/piw_macOS.jpg)


## How to build and run (on Linux)

Clone the project

```bash
git clone https://github.com/yunusem/pardus-imagewriter.git
```
Install build dependencies

```bash
sudo apt-get install build-essential libc6 libgcc1 libgl1-mesa-glx libgl1 \
libqt5core5a libqt5dbus5 libqt5gui5l ibqt5network5 libqt5qml5 libqt5quick5 \
libqt5svg5-dev libqt5widgets5 libstdc++6 libudev-dev qtdeclarative5-dev
```

Build

```bash
cd pardus-imagewriter
mkdir build
cd build
export QT_SELECT=qt5
qmake ../
make
```

Install Runtime dependencies

```bash
sudo apt install gksu libqt5svg5 qml-module-qtquick-controls2  \
qml-module-qt-labs-folderlistmodel qml-module-qtquick2 \
qml-module-qtquick-layouts qml-module-qtgraphicaleffects \
qml-module-qtquick-dialogs qml-module-qtquick-controls \
qml-module-qtquick-templates2 qml-module-qt-labs-settings
```

Run

```bash
gksudo ./piw
```
