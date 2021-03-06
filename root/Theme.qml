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

import QtWebService.HTML 5.0

Html {
    id: root

    property string __title: 'Qt { version: 5 }'
    property string __subtitle
    default property alias contents: main.contents
    property alias aside: aside.contents
    property alias head: head.contents
    property bool __tracking: true
    property string __mode

    Head {
        id: head
        enabled: http.status === 200
        Meta { charset: "utf-8" }
        Meta { http_equiv: "X-UA-Compatible"; content: "IE=edge,chrome=1" }
        Meta { name: "description"; content: "" }
        Meta { name: "viewport"; content: "width=device-width" }
        Title { text: root.__subtitle.length > 0 ? '%1 - %2'.arg(root.__subtitle).arg(root.__title) : root.__title }
        Link { rel: "shortcut icon"; href: "/favicon.ico" }
        Link { rel: "contents"; href: "http://%1%2/sitemap.qml".arg(http.host).arg(http.port === 80 ? '' : ':' + http.port) }
        Link { rel: "alternate"; type: "application/rss+xml"; title: "RSS"; href: "http://%1%2/rss.qml".arg(http.host).arg(http.port === 80 ? '' : ':' + http.port) }
        Link { rel: "stylesheet"; href: "/css/" }
        Script {
            enabled: root.__mode == 'edit'
            type: 'text/javascript'; src: 'http://code.jquery.com/jquery-1.8.3.min.js'
        }
    }

    Body {
        enabled: http.status === 200
        Div {
            _class: "header-container"
            Header {
                _class: "wrapper clearfix"
                H1 {
                    _class: "title"
                    A {
                        href: '/'
                        text: root.__title
                    }
                }

                Nav {
                    Ul {
                        Li {
                            A {
                                href: "www.qt.io/download-open-source/"
                                text: "Download"
                                target: '_blank'
                            }
                        }
                        Li {
                            A {
                                href: "https://bugreports.qt.io/"
                                text: "Bug report"
                                target: '_blank'
                            }
                        }
                        Li {
                            A {
                                href: "http://wiki.qt.io/Qt_Contribution_Guidelines"
                                text: "Bug fix"
                                target: '_blank'
                            }
                        }
                    }
                }
            }
        }

        Div {
            _class: "main-container"
            Div {
                _class: "main wrapper clearfix"

                Div {
                    id: main
                    _id: "main"
//                    property string style: "width: 100%"
                }

                Aside { id: aside }
            }
        }

        Div {
            _class: "footer-container"
            Footer {
                _class: "wrapper"
                H3 {
                    Text { text: '&copy; 2012 - %1 '.arg(Qt.formatDate(new Date(), 'yyyy')) }
                    A {
                        href: 'mailto: stasuku+blog@gmail.com'
                        text: 'Tasuku Suzuki'
                    }
                }
            }
        }

        GoogleAnalytics {
            enabled: http.host === "qt5.jp" && root.__tracking
            __trackingCode: 'UA-37175896-1'
        }
    }
}
