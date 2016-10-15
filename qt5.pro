TEMPLATE = app
TARGET = qt5.jp
QT = webservice
CONFIG += install_ok
SOURCES += main.cpp
RESOURCES += main.qrc \
    main.qrc

OTHER_FILES += \
    root/components/Button.qml \
    root/components/ButtonGroup.qml \
    root/components/PlainFile.qml \
    root/components/Terminal.qml \
    root/css/Button.qml \
    root/css/index.qml \
    root/css/PlainFile.qml \
    root/css/Terminal.qml \
    root/edit.js \
    root/favicon.ico \
    root/icons/document-close.png \
    root/icons/document-new.png \
    root/icons/document-properties.png \
    root/icons/page.png \
    root/icons/rss.png \
    root/icons/system-log-out.png \
    root/plugins/api/Plugin.qml \
    root/plugins/highlight/cpp.js \
    root/plugins/highlight/json.js \
    root/plugins/highlight/pro.js \
    root/plugins/highlight/qml.js \
    root/plugins/include.qml \
    root/plugins/highlight.qml \
    root/Theme.qml \
    root/GoogleAnalytics.qml \
    root/UserModel.qml \
    root/UserInput.qml \
    root/Twitter.qml \
    root/TagModel.qml \
    root/sitemap.qml \
    root/rss.qml \
    root/ArticleModel.qml \
    root/Account.qml \
    root/AbstractSlugModel.qml \
    root/index.qml
