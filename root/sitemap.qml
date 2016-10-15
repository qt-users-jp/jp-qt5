/* Copyright (c) 2012 QtWebService Project.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the QtWebService nor the
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
import QtWebService.HTML 5.0
import QtWebService.Utils 1.0
import me.qtquick.Database 0.1

Text {
    id: root
    property string contentType: "text/plain; charset=utf-8;"

    WebServiceConfig {
        id: config
        property variant blog: {author: 'task_jp'; database: ':memory:'; title: 'Qt { version: 5 }'}
    }

    Database {
        id: db
        connectionName: 'blog'
        type: "QSQLITE"
        databaseName: config.blog.database
    }

    ArticleModel {
        id: articleModel
        database: db
        condition: 'published <> "" AND published < ?'
        params: [new Date()]
        onCountChanged: {
            var urls = []
            for (var i = 0; i < count; i++) {
                urls.push('%1://%2/%3.html'.arg(http.scheme).arg(http.host).arg(articleModel.get(i).slug))
            }
            root.text = urls.join('\n')
        }
        Component.onCompleted: articleModel.select = true
    }
}
