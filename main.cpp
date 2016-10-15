#include <QtCore/QCoreApplication>
#include <QtWebService/QWebServiceEngine>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    QWebServiceEngine engine(QStringLiteral(":/config.qml"));
    engine.start();

    return app.exec();
}
