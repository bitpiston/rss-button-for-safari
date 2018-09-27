/**
 * The MIT License (MIT)
 *
 * Copyright © 2015 Reda Lemeden.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the “Software”), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 * following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
 * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Modified by Jan Pingel on 2018-09-20.
 */

'use strict';

var feeds = [],
    parsed = false;

document.addEventListener("DOMContentLoaded", function(event) {
    extractFeeds();
});

/*
window.addEventListener("pagehide", function(event) {
    if (isValidPage() && !event.persisted) {
        safari.extension.dispatchMessage("pageUnloaded");
    }
});
*/

function isValidPage() {
    return (window.top === window && document.domain !== "undefined" && window.location.href !== "favorites://");
}

function extractFeeds(setParsed = true) {
    if (!isValidPage() || parsed === true) { return };
    
    if (!feeds.length > 0) {
        var headLinks = document.querySelectorAll("head > link[rel='alternate']");
        
        for (var i = 0; i < headLinks.length; i++) {
            console.log("loop: " + i);
            var link = headLinks[i];
            
            if (link.attributes.getNamedItem("rel") !== null && link.attributes.getNamedItem("rel").value == "alternate") {
                var type = link.attributes.getNamedItem("type").value;
                
                if (type !== null) {
                    if (type == "application/rss+xml" || type == "application/atom+xml" || type == "text/xml") {
                        var href  = link.attributes.getNamedItem("href").value,
                            title = link.attributes.getNamedItem("title").value,
                            type  = typeFromString(type);

                        if (title) {
                            title = toTitleCase(title);
                        } else {
                            title = titleFromType(typeValue);
                        }
                        
                        if (href) {
                            feeds.push({url: _fullUrl(href), title: title, type: type});
                        }
                    }
                }
            }
        }
    }
    
    if (setParsed === true) {
        parsed = true;
    }
    
    if (feeds.length > 0) {
        safari.extension.dispatchMessage("extractedFeeds", {feeds: feeds});
    }
}

function protocol(url) {
    return url.split(":")[0];
}

function typeFromString(string) {
    var type;
    
    if (string.indexOf("rss") != -1) {
        type = "RSS";
    } else if (string.indexOf("atom") != -1) {
        type = "Atom";
    } else {
        type = "Unknown";
    }
    
    return type;
}

function titleFromType(type) {
    var title;
    
    if (type.indexOf("rss") != -1) {
        title = "RSS Feed";
    } else if (type.indexOf("atom") != -1) {
        title = "Atom Feed";
    } else {
        title = "Feed";
    }
    
    return title;
}

function toTitleCase(str) {
    return str.replace(/\w\S*/g, function(txt) {
       return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
    });
}

function _getBaseUrl() {
    var head = document.getElementsByTagName("head")[0];
    var baseLinks = head.getElementsByTagName("base");
    var baseUrl;
    
    for (var i=0; i < baseLinks.length; i++) {
        var link = baseLinks[i];
        
        if (link.attributes.getNamedItem("href") !== null) {
            url = link.attributes.getNamedItem("href").value;
            
            if (url.charAt(url.length - 1) != "/") {
                url += "/";
            }
            
            baseUrl = url;
            break;
        }
    }
    
    if (baseUrl === undefined) {
        baseUrl = protocol(document.URL) + "://" + document.domain + "/"
    }
    
    return baseUrl;
}

function _fullUrl(url) {
    var trimmedUrl = url.trim();
    var protocol = trimmedUrl.substr(0,4);
    
    if (protocol !== "http" && protocol !== "feed") {
        if (trimmedUrl[0] == "/") {
            trimmedUrl = trimmedUrl.slice(1);
        }
        
        trimmedUrl = _getBaseUrl() + trimmedUrl;
    }
    
    return trimmedUrl;
}
