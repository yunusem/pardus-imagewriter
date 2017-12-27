#ifndef DEVICEHANDLER_H
#define DEVICEHANDLER_H

#include <QObject>

class DeviceHandler : public QObject
{
    Q_OBJECT
public:
    explicit DeviceHandler(QObject *parent = 0);

signals:

public slots:
};

#endif // DEVICEHANDLER_H
