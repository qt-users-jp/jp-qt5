import Silk.Config 0.1

Config {
    listen: Listen {
        address: '*'
        port: 6109
    }

    property string root: '/jp/qt5'

    contents: {
        '/': root,
        '/uploads': root + '/data/uploads'
    }

    cache: {
        'qml': false
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

    property var blog: { "author": "", "database": root + "/data/blog.sqlite", "title": "Qt { version: 5 }", "upload": root + "/data/uploads/" }
}
