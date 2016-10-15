import QtWebService.Config 0.1

Config {
    listen.address: '*'
    listen.port: 8080
    server.name: 'qt5.jp'

    property string data: '/jp/qt5/data'

    contents: {
        '/': './root/',
        '/upload': data
    }

    cache: {
        'qml': true
    }

    deflate: {
        'video/*': false
        , 'image/*': false
    }

    rewrite: {
        "^(https?://[^/]+/)([0-9]+)\\.html\\??(.*?)$": "$1?no=$2&$3"
        , "^(https?://[^/]+/)(.+)\\.html\\??(.*?)$": "$1?slug=$2&$3"
        , "^(https?://[^/]+/)([0-9]+)$": "$1?page=$2"
    }

    property var oauth: { "consumerKey": "", "consumerSecret": "" }

    property var blog: { "author": "", "database": data + "/blog.sqlite", "title": "", "upload": data + "/upload/" }
}
