/* Copyright (c) 2012 Silk Project.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Silk nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL SILK BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQml 2.0
import Silk.HTML 5.0
import Silk.Cache 1.0
import Silk.Database 1.0
import Silk.Utils 1.0
import './components/'

Theme {
    id: root
    __title: config.blog.title
    __tracking: !account.loggedIn
    __mode: input.action

    SilkConfig {
        id: config
        property variant blog: {author: 'task_jp'; database: ':memory:'; title: 'Qt { version: 5 }'}
        property variant contents: {}
    }

    UserInput {
        id: input
        property string action
        property string subaction

        // for list
        property string label: ''
        property int page: 1

        // for details
        property int no
        property string slug

        // for edit
        property string title
        property string head
        property string body
        property string body2
        property string yymmdd: ''
        property string hhmm: ''

        // for login
        property string oauth_token
        property string oauth_verifier

        onSubmit: {
            // account
            switch(input.action) {
            case 'login':
                account.login()
                return
            case 'logout':
                account.logout()
                return
            default:
                if (input.oauth_verifier.length > 0) {
                    account.verified(input.oauth_token, input.oauth_verifier)
                    return
                } else if (typeof http.requestCookies.session_id !== 'undefined') {
                    account.restoreSession()
                }
                break
            }

            // edit
            if (account.loggedIn) {
                switch(input.action) {
                case 'edit':
                    switch(input.subaction) {
                    case 'save':
                        editor.save()
                        break
                    default:
                        editor.load()
                        break
                    }
                    break
                case 'remove':
                    switch(input.subaction) {
                    case 'remove':
                        editor.remove()
                        break
                    default:
                        articleModel.condition = 'id=%1'.arg(input.no)
                        articleModel.select = true
                        editor.confirmRemove = true
                        break
                    }
                    break
                default:
                    break
                }
            }

            // view
            if (input.action.length === 0) {
                var conditions = []
                var params = []
                if (!account.loggedIn) {
                    conditions.push('published <> ""')
                    conditions.push('published < ?')
                    params.push(new Date())
                }
                if (input.page > 0)
                    articleModel.offset = articleModel.limit * Math.max(0, input.page - 1)
                if (input.no > 0) {
                    conditions.push('id=?')
                    params.push(input.no)
                }
                if (input.slug.length > 0) {
                    conditions.push("slug=?")
                    params.push(input.slug)
                }
                articleModel.condition = conditions.join(' AND ')
                articleModel.params = params
                articleModel.select = true
                if (viewer.detail && articleModel.count === 1)
                    root.__subtitle = articleModel.get(0).title
                articleCount.select = true
            }
        }
    }

    Account {
        id: account
        author: config.blog.author
    }

    // Editor
    QtObject {
        id: editor
        property bool isNew: !(input.no > 1)
        property bool confirmRemove: false
        property variant errors: []

        function checkError() {
            var ret = false
            var messages = []
            if (input.title.length === 0) {
                messages.push(qsTr('Title is empty'))
                ret = true
            }

            if (input.slug.length === 0) {
                if (input.title.length !== 0) {
                    input.slug = input.title
                    ret = true
                }
            }

            if (input.body.length === 0) {
                messages.push(qsTr('Body is empty'))
                ret = true
            }

            errors = messages
            return ret
        }

        function load() {
            if (input.no > 0) {
                articleModel.condition = 'id=?'
                articleModel.params = [input.no]
                articleModel.select = true
                var article = articleModel.get(0)
                input.title = article.title
                input.slug = article.slug
                input.body = article.body
                input.body2 = article.body2
                input.head = article.head
                input.yymmdd = Qt.formatDate(article.published, 'yyyy-MM-dd')
                input.hhmm = Qt.formatTime(article.published, 'hh:mm')
            }
        }

        function save() {
            if (checkError()) return
            if (db.transaction()) {
                var article = {}
                article.user_id = 1
                article.title = input.title
                article.slug = input.slug
                article.body = input.body
                article.body2 = input.body2
                article.head = input.head
                article.published = new Date(input.yymmdd + ' ' + input.hhmm)
                article.lastModified = new Date()

                if (editor.isNew) {
                    input.no = articleModel.insert(article)
                } else {
                    article.id = input.no
                    articleModel.update(article)
                }

                if (db.commit()) {
                    if (http.files.length > 0) {
                        for (var i = 0; i < http.files.length; i++) {
                            http.files[i].save('%1%2/%3'.arg(config.blog.upload).arg(input.no).arg(http.files[i].fileName))
                        }
                    }
                    http.status = 302
                    http.responseHeader = {'Content-Type': 'text/plain; charset=utf-8;', 'Location': '%1?no=%2'.arg(http.path).arg(input.no)}
                } else {
                    db.rollback()
                    errors = [qsTr('Save failed. try again')]
                }
            } else {
                errors = [qsTr('Save failed. try again')]
            }
        }

        function remove() {
            if (db.transaction()) {
                articleModel.remove({id: input.no})
                if (db.commit()) {
                    http.status = 302
                    http.responseHeader = {'Content-Type': 'text/plain; charset=utf-8;', 'Location': '%1'.arg(http.path)}
                } else {
                    db.rollback()
                    errors = [qsTr('Delete failed. try again')]
                }
            } else {
                errors = [qsTr('Delete failed. try again')]
            }
        }
    }

    // Viewer
    QtObject {
        id: viewer
        property bool detail: input.no > 0 || input.slug.length > 0

        property var plugins

        Component.onCompleted: {
            var plugins = {}
            var dir = config.contents['*'] + 'plugins/'
            var files = Silk.readDir(dir)
            for (var i = 0; i < files.length; i++) {
                var component = Qt.createComponent(dir + files[i])
                switch (component.status) {
                case Component.Ready: {
                    var plugin = component.createObject(viewer, {config: config})
                    plugins[plugin.name] = plugin.exec
                    break }
                case Component.Error:
                    console.debug(component.errorString())
                    break
                default:
                    console.debug(component.status)
                    break
                }
            }
            viewer.plugins = plugins
        }

        function show(html, no) {
            html = html.replace(/plugin/g, '\v')
            while (html.match(/<\v type=\"([^"]+)\" argument=\"([^"]+)\">([^\v]*?)<\/\v>/)) {
                html = html.replace(/<\v type=\"([^"]+)\" argument=\"([^"]+)\">([^\v]*?)<\/\v>/gm, function(str, plugin, argument, innerText) {
                    var ret = str
                    if (typeof viewer.plugins[plugin] === 'undefined') {
                        console.debug('plugin %1 not found.'.arg(plugin))
                        ret = innerText
                    } else {
                        ret = (viewer.plugins[plugin])(argument.replace('[id]', no), innerText, false)
                    }
                    return ret
                })
            }
            html = html.replace(/\v/g, 'plugin')
            return html
        }
    }

    Database {
        id: db
        connectionName: 'blog'
        type: "QSQLITE"
        databaseName: config.blog.database
    }

    UserModel { id: userModel; database: db }
    TagModel { id: tagModel; database: db }
    ArticleModel {
        id: articleModel
        database: db
        limit: 10
    }
    SelectSqlModel {
        id: articleCount
        database: db
        select: false
        query: account.loggedIn ? 'SELECT COUNT(id) AS article_count FROM Article' : 'SELECT COUNT(id) AS article_count FROM Article WHERE published < ? AND published <> ""'
        params: account.loggedIn ? [] : [new Date()]

        property int article_count: 0
        onCountChanged: if (count > 0) article_count = get(0).article_count
        property int pages: Math.floor(articleCount.article_count / 10 + (articleCount.article_count % 10 > 0 ? 1 : 0))
    }

    head: [
        Script { type: 'text/javascript'; src: '/edit.js'; enabled: input.action === 'edit' }
    ]
    aside: [
        Ul {
            Li {
                A {
                    href: 'http://twitter.com/%1'.arg(config.blog.author)
                    target: '_blank'
                    Img { width: '22'; height: '22'; src: 'http://api.twitter.com/1/users/profile_image?screen_name=%1'.arg(config.blog.author) }
                    Text { text: config.blog.author }
                }
                Ul {
                    enabled: account.loggedIn
                    Li {
                        A {
                            href: "/?action=edit"
                            Img { width: '22'; height: '22'; src: '/icons/document-new.png' }
                            Text { text: "New" }
                        }
                    }
                    Li {
                        enabled: account.loggedIn && input.no > 0
                        A {
                            href: "/?action=edit&no=%1".arg(input.no)
                            Img { width: '22'; height: '22'; src: '/icons/document-properties.png' }
                            Text { text: "Edit" }
                        }
                    }
                    Li {
                        enabled: account.loggedIn && input.no > 0
                        A {
                            href: "/?action=remove&no=%1".arg(input.no)
                            Img { width: '22'; height: '22'; src: '/icons/document-close.png' }
                            Text { text: "Delete..." }
                        }
                    }
                    Li {
                        A {
                            href: "/?action=logout"
                            Img { width: '22'; height: '22'; src: '/icons/system-log-out.png' }
                            Text { text: "Logout" }
                        }
                    }
                }
            }
            Repeater {
                model: articleCount.pages
                enabled: input.no === 0 && model > 1
                Component {
                    Li {
                        A {
                            enabled: model.modelData !== input.page - 1
                            href: '%1?page=%2'.arg(http.path).arg(model.modelData + 1)
                            Img { width: '22'; height: '22'; src: '/icons/page.png' }
                            Text { text: 'Page: %1'.arg(model.modelData + 1) }
                        }
                        Strong {
                            enabled: model.modelData === input.page - 1
                            Img { width: '22'; height: '22'; src: '/icons/page.png' }
                            Text { text: 'Page: %1'.arg(model.modelData + 1) }
                        }
                    }
                }
            }
            Li {
                A {
                    href: "http://%1%2/rss.qml".arg(http.host).arg(http.port === 80 ? '' : ':' + http.port)
                    Img { width: '22'; height: '22'; src: '/icons/rss.png' }
                    Text { text: qsTr('RSS') }
                }
            }
        }
    ]

    function escapeHTML(str) {
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    }
    function escapeAll(str) {
        return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    }


    Article {
        enabled: input.action === 'edit'

        Header {
            H2 { text: editor.isNew ? qsTr('New') : qsTr('Edit') }
            Repeater {
                model: editor.errors
                Component {
                    H3 {
                        text: model.modelData
                    }
                }
            }
        }
        Form {
            action: http.path
            method: 'POST'
            enctype: "multipart/form-data"

            Input {
                type: 'text'
                name: 'title'
                placeholder: qsTr('Title')
                value: escapeAll(input.title)
                property string style: "width: 100%"
            }
            Input {
                type: 'text'
                name: 'slug'
                placeholder: qsTr('Slug')
                value: escapeAll(input.slug)
                property string style: "width: 100%"
            }
            TextArea {
                name: 'body'
                placeholder: qsTr('Body')
                rows: '15'
                property string style: "width: 100%"
                Text { text: escapeAll(input.body) }
            }
            TextArea {
                name: 'body2'
                placeholder: qsTr('Continue')
                rows: '20'
                property string style: "width: 100%"
                Text { text: escapeAll(input.body2) }
            }
            Repeater {
                model: Silk.readDir('%1%2'.arg(config.blog.upload).arg(input.no))
                Component {
                    Input { type: 'checkbox'; _id: value; value: model.modelData }
                }
                Component {
                    Label { _for: text; text: model.modelData }
                }
                Component {
                    Br {}
                }
            }

            Input { type: 'file'; name: 'file' } Br {}
            Input { type: 'date'; name: 'yymmdd'; value: input.yymmdd }
            Input { type: 'time'; name: 'hhmm'; value: input.hhmm }
            Input { type: 'submit'; value: qsTr('Save') }
            Input { type: 'hidden'; name: 'action'; value: input.action }
            Input { type: 'hidden'; name: 'subaction'; value: 'save' }
            Input { type: 'hidden'; name: 'no'; value: input.no }
            TextArea {
                name: 'head'
                placeholder: qsTr('Head')
                property string style: "width: 100%"
                Text { text: input.head }
            }
        }
    }

    // Viewer
    Repeater {
        enabled: input.action !== 'edit'
        model: articleModel
        Component {
            Article {
                Header {
                    H2 {
                        A {
                            href: '%1%2.html'.arg(http.path).arg(model.slug)
                            text: escapeHTML(model.title)
                        }
                        A {
                            enabled: account.loggedIn
                            href: '%1?action=edit&no=%2'.arg(http.path).arg(model.id)
                            Img { width: '22'; height: '22'; src: '/icons/document-properties.png' }
                        }
                    }
                    P {
                        _class: 'dates'
                        Text { text: qsTr('Published: %1').arg(Qt.formatDateTime(model.published, qsTr('yyyy-MM-dd'))) }
                        Text {
                            enabled: model.published < model.lastModified
                            text: qsTr(' / Last modified: %1').arg(Qt.formatDateTime(model.lastModified, qsTr('yyyy-MM-dd')))
                        }
                    }
                }

                Section {
                    id: body
                    Text { text: viewer.show(model.body, model.id) }
                    Text {
                        enabled: viewer.detail && model.body2.length > 0
                        text: enabled ? viewer.show(model.body2, model.id) : ''
                    }
                    P {
                        _class: 'continue'
                        A {
                            enabled: !viewer.detail && model.body2.length > 0
                            href: '%1%2.html'.arg(http.path).arg(model.slug)
                            text: qsTr('Continue reading...')
                        }
                    }
                }

                Footer {
                    enabled: editor.confirmRemove
                    H2 { text: qsTr('Are you sure to delete?') }
                    Button {
                        __text: qsTr('Delete')
                        href: '%1?action=remove&subaction=remove&no=%2'.arg(http.path).arg(input.no)
                    }
                    Button {
                        __text: qsTr('Cancel')
                        href: '%1?no=%2'.arg(http.path).arg(input.no)
                    }
                }
            }
        }
    }

    Nav {
        _class: 'footer-nav'
        A {
            enabled: input.page > 1 && !viewer.detail
            href: '%1?page=%2'.arg(http.path).arg(input.page - 1)
            text: qsTr('Previous')
        }
        Span {
            enabled: input.page < 2 && !viewer.detail
            text: qsTr('Previous')
        }
        A { href: '#top'; text: qsTr('Top') }
        A {
            enabled: input.page < articleCount.pages && !viewer.detail
            href: '%1?page=%2'.arg(http.path).arg(input.page + 1)
            text: qsTr('Next')
        }
        Span {
            enabled: input.page > articleCount.pages - 1 && !viewer.detail
            text: qsTr('Next')
        }
    }
}
