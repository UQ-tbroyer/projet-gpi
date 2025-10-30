#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    // Chemin local, pas une ressource .qrc
    engine.load(QUrl::fromLocalFile("C:/Users/david/source/repos/QtQuickApplication1/QtQuickApplication1/main2.qml"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
