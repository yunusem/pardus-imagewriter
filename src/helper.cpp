/*****************************************************************************
 *   Copyright (C) 2017 by Yunusemre Senturk                                 *
 *   <yunusemre.senturk@pardus.org.tr>                                       *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 *****************************************************************************/
#include "src/helper.h"
#include "src/common.h"
#include "src/usbdevicemonitor.h"
#include "src/usbdevice.h"
#include "src/imagewriter.h"
#if defined(Q_OS_LINUX)
#include "src/signalhandler.h"
#include <QProcess>
#endif
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QStringList>
#include <QThread>
#include <QStandardPaths>
#include <QUrl>
#include <QCoreApplication>
#include <QDebug>

Helper::Helper(QObject *parent) : QObject(parent),
    progressValue(0), maxValue(1),comboBoxIndex(-1), b(false), retryCount(0)
{

#if defined(Q_OS_LINUX)
    SignalHandler *sh = new SignalHandler;
    sh->setHelper(this);
#endif
    udm = new UsbDeviceMonitor(this);
    udm->startMonitoring();

    scheduleEnumFlashDevices();

    connect(udm, SIGNAL(deviceChanged()),this,SLOT(scheduleEnumFlashDevices()));

}

bool Helper::burning() const
{
    return this->b;
}

int Helper::progress() const
{
    return progressValue;
}

QString Helper::messageFromBackend() const
{
    return m_messageFromBackend;
}

QString Helper::filePathFromArguments() const
{
    const QStringList args = QCoreApplication::arguments();
    QString path = "";
    if(args.length() > 1) {
        path =  args.at(1);
        QString suffix = QFileInfo(path).suffix();
        if( suffix == "iso" || suffix == "bin" || suffix == "img" ||
                suffix == "ISO" || suffix == "BIN" || suffix == "IMG") {
            path = QDir(path).absolutePath();
        }
    }
    return path;
}

QString Helper::fileNameFromPath(const QString &path) const
{
    return QFileInfo(path).fileName();
}

QString Helper::downloadsFolderPath() const
{
    QStringList downloadDirs = QStandardPaths::standardLocations(QStandardPaths::DownloadLocation);
    if (downloadDirs.size() > 0)
        return downloadDirs.at(0);
    else
        return "";
}

QStringList Helper::devices()
{
    return dl;
}

void Helper::scheduleEnumFlashDevices()
{
    emit scheduleStarted();
    comboBoxIndex = -1;
    udl = platformEnumFlashDevices();
    dl.clear();
    for(int i = 0; i < udl.length(); i++) {
        dl.append(udl.at(i).formatDisplayName());
    }
    emit deviceListChanged();
}

bool Helper::preProcessImageFile(const QString &fileUrl)
{
    QString newImageFile = fileUrl;
    if(fileUrl.left(7) == "file://") {
        newImageFile = QUrl(fileUrl).toLocalFile();
        newImageFile = QDir(newImageFile).absolutePath();
    }
    QFile f(newImageFile);
    if (!f.open(QIODevice::ReadOnly)) {
        qDebug() << "Pre Process : " << QDir::toNativeSeparators(newImageFile) << f.errorString();
        return false;
    }
    imageSize = f.size();
    f.close();
    imageFile = newImageFile;
    return true;
}

void Helper::writeToDevice(int index)
{
    comboBoxIndex = index;
    progressValue = 0;
    maxValue = 1;
    if(dl.length() == 0 || imageFile == "") {
        qDebug() << "Could not find the device or the image file";
        return;
    }

    UsbDevice selectedDevice = udl.at(comboBoxIndex);
    maxValue = alignNumberDiv(imageSize, DEFAULT_UNIT);
    ImageWriter *writer = new ImageWriter(imageFile, selectedDevice);
    QThread *writerThread = new QThread(this);

    connect(writerThread, SIGNAL(started()), writer, SLOT(writeImage()));
    connect(writer, SIGNAL(finished()), writerThread, SLOT(quit()));
    connect(writer, SIGNAL(finished()), writerThread, SLOT(deleteLater()));
    connect(writerThread, SIGNAL(finished()), writerThread, SLOT(deleteLater()));

    connect(this,SIGNAL(cancelWritingProcess()),writer,SLOT(cancelWriting()),Qt::DirectConnection);
    connect(writer, SIGNAL(blockWritten(int)), this, SLOT(updateProgressValue(int)));

    connect(writer, SIGNAL(error(QString)), this, SLOT(output(QString)));

    connect(writer,SIGNAL(success()),this,SIGNAL(burningFinished()));

    connect(writer,SIGNAL(cancelled()),this, SIGNAL(burningCancelled()));


    writer->moveToThread(writerThread);
    writerThread->start();
}

void Helper::cancelWriting()
{
    emit cancelWritingProcess();
}

quint64 Helper::getImageSize() const
{
    return imageSize;
}

quint64 Helper::getSelectedDeviceSize(const int index) const
{
    return udl.at(index).m_Size;
}

void Helper::notifySystem(const QString &title, const QString &content)
{
    qDebug() << content;
#if defined(Q_OS_LINUX)
    QProcess p;
    QStringList args;
    args << "-u" << "normal";
    args << "-t" << "17000";
    args << "-i" << "/usr/share/pardus/pardus-imagewriter/icon.svg";
    args << title << content;

    QString command = "/usr/bin/notify-send";
    p.execute(command,args);
#endif
}

int Helper::maximumProgressValue()
{
    return maxValue;
}

void Helper::updateProgressValue(int increment)
{
    progressValue += increment;
    emit progressChanged();
}

void Helper::output(QString msg)
{
    m_messageFromBackend = msg;
    if (msg.contains("control block address is invalid",Qt::CaseInsensitive)) {
        qDebug() << msg;
        qDebug() << "Retrying to write";
        if(retryCount < 3) {
            retryCount ++;
            writeToDevice(comboBoxIndex);
        } else {
            emit warnUser();
            emit burningCancelled();
            qDebug() << msg;
        }

    } else {
        emit warnUser();
        emit burningCancelled();
        qDebug() << msg;
    }
}
