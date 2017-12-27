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
#include "signalhandler.h"
#include "helper.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <QSocketNotifier>
#include <QDebug>

int SignalHandler::sigFd[2];

SignalHandler::SignalHandler(QObject *parent) : QObject(parent)
{
    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigFd)) {
        qFatal("Couldn't create socketpair");
    }
    sig = new QSocketNotifier(sigFd[1], QSocketNotifier::Read, this);
    connect(sig, SIGNAL(activated(int)), this, SLOT(handleSignalSlot()));

}

void SignalHandler::setHelper(Helper *h)
{
    helper = h;
}

void SignalHandler::handleSignals(int)
{
    char a = 1;
    ::write(sigFd[0], &a, sizeof(a));
}

void SignalHandler::handleSignalSlot()
{
    sig->setEnabled(false);
    char tmp;
    ::read(sigFd[1], &tmp, sizeof(tmp));

    emit helper->terminateCalled();

    sig->setEnabled(true);
}
