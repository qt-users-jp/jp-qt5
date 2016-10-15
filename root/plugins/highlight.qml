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

import './api/'
import './highlight/qml.js' as QmlParser
import './highlight/json.js' as JsonParser
import './highlight/pro.js' as ProParser
import './highlight/cpp.js' as CppParser

Plugin {
    id: root
    name: 'highlight'

    function exec(argument, str, preview) {
        if (preview) return str
        var parser
        var ret = str
        switch (argument) {
        case 'qml':
            parser = new QmlParser.QmlParser()
            ret = parser.to_html(parser.parse(str))
            break
        case 'cpp':
            parser = new CppParser.CppParser()
            ret = parser.to_html(parser.parse(str))
            break
        case 'json':
            parser = new JsonParser.JsonParser()
            ret = parser.to_html(parser.parse(str))
            break
        case 'pro':
            parser = new ProParser.ProParser()
            ret = parser.to_html(parser.parse(str))
            break
        default:
            break
        }

        return ret
    }
}