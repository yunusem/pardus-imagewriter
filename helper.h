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
#ifndef HELPER_H
#define HELPER_H


#include "usbdevice.h"
#include <QObject>
#include <QList>
#include <QString>


class QStringList;
class UsbDeviceMonitor;


class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool burning READ burning
               NOTIFY burningFinished
               NOTIFY terminateCalled)
    Q_PROPERTY(QStringList devices READ devices NOTIFY deviceListChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)

public:
    explicit Helper(QObject *parent = 0);
    bool burning() const;
    QStringList devices();
    int progress() const;
    Q_INVOKABLE QString fileNameFromPath(const QString &path) const;
    Q_INVOKABLE bool preProcessImageFile(const QString &newImageFile);
    Q_INVOKABLE void writeToDevice(int index);
    Q_INVOKABLE int maximumProgressValue();
    Q_INVOKABLE QString downloadsFolderPath() const;
private:
    QString imageFile;
    quint64 imageSize;
    int progressValue;
    int maxValue;
    bool b;
    QStringList dl;
    UsbDeviceMonitor *udm;
    QList<UsbDevice> udl;
signals:
    void progressChanged();
    void deviceListChanged();
    void burningFinished();
    void terminateCalled();
private slots:
    void scheduleEnumFlashDevices();
    void updateProgressValue(int increment);
    void output(QString msg);
};

#endif // HELPER_H
