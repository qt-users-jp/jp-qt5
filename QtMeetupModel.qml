import QtQml 2.2
import QtQml.Models 2.1

ListModel {
    id: root
    Component.onCompleted: {
        var http = new XMLHttpRequest
        http.onreadystatechange = function() {
            switch (http.readyState) {
            case XMLHttpRequest.HEADERS_RECEIVED:
//                console.debug(http.statusText)
                break
            case XMLHttpRequest.DONE: {
                var lines = http.responseText.split(/\r?\n/)
                for (var i in lines) {
                    var fields = lines[i].split(/\t/)
                    if (fields.length !== 5) continue
                    root.insert(0, {'date': new Date(fields[0], fields[1] - 1, fields[2]), 'title': fields[3], 'link': fields[4]})
                }
                break }
            }
        }
        http.open("GET", "meetups.txt")
        http.send()
    }
}
