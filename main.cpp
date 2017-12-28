#include "helper.h"
#if defined(Q_OS_LINUX)
#include "signalhandler.h"
#include <signal.h>
#endif
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLocale>
#include <QIcon>

#include <QDebug>

#if !defined(Q_OS_WIN32) && !defined(Q_OS_LINUX) && !defined(Q_OS_MAC)
#error Unsupported platform!
#endif

#if defined(Q_OS_LINUX)
static int setup_unix_signal_handlers()
{
    struct sigaction sig;
    sig.sa_handler = SignalHandler::handleSignals;
    sigemptyset(&sig.sa_mask);
    sig.sa_flags = 0;
    sig.sa_flags |= SA_RESTART;

    if (sigaction(SIGINT, &sig, 0)) {
        return 1;
    }

    if (sigaction(SIGTERM, &sig, 0)) {
        return 2;
    }

    if (sigaction(SIGHUP, &sig, 0)) {
        return 3;
    }

    return 0;
}
#endif

int main(int argc, char *argv[])
{
#if defined(Q_OS_MAC)
    // On Mac OS X elevated launch is treated as setuid which is forbidden by default -> enable it
    // TODO: Try to find a more "kosher" way, as well as get rid of deprecated AuthorizationExecuteWithPrivileges()
    QCoreApplication::setSetuidAllowed(true);
#endif
    qmlRegisterType<Helper>("piw.helper",1,0,"Helper");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setWindowIcon(QIcon(":/images/icon.svg"));
    QGuiApplication app(argc, argv);

    QTranslator t;
        if (t.load(":/translations/piw_" + QLocale::system().name())) {
            app.installTranslator(&t);
        } else {
            qDebug() << "Could not load the translation";
        }

#if defined(Q_OS_LINUX)
    setup_unix_signal_handlers();
#endif
    /*
    if (!ensureElevated()) {
        return 1;
    }
    */
#if defined(Q_OS_WIN32)
    // CoInitialize() seems to be called by Qt automatically, so only set security attributes
    HRESULT res = CoInitializeSecurity(NULL, -1, NULL, NULL, RPC_C_AUTHN_LEVEL_PKT, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE, 0);
    if (res != S_OK)
    {
        printf("CoInitializeSecurity failed! (Code: 0x%08lx)\n", res);
        return res;
    }
#endif

    QQmlApplicationEngine engine;
    engine.load(QUrl(QLatin1String("qrc:/ui/main.qml")));

    return app.exec();
}


