/*
 * Based on Syndicate: https://github.com/kaishin/syndicate/
 *
 * Copyright (c) 2015 Reda Lemeden
 * Copyright (c) 2018 BitPiston Studios
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

'use strict';

var feeds = [],
    parsed = false;

document.addEventListener("DOMContentLoaded", function(event) {
    if (isValidPage()) {
        extractFeeds();
    }
});

/*
window.addEventListener("pagehide", function(event) {
    if (isValidPage() && !event.persisted) {
        safari.extension.dispatchMessage("pageUnloaded");
    }
});
*/

function isValidPage() {
    return (window.top === window &&
            typeof safari != "undefined" &&
            (document.domain !== "undefined" || document.location != null) &&
            window.location.href !== "favorites://");
}

function extractFeeds(setParsed = true) {
    if (parsed === true) { return };
    
    if (!feeds.length > 0) {
        var headLinks = document.querySelectorAll("head > link[rel='alternate']");
        
        for (var i = 0; i < headLinks.length; i++) {
            var link = headLinks[i];
            
            if (link.attributes.getNamedItem("rel") !== null &&
                link.attributes.getNamedItem("rel").value == "alternate" &&
                link.attributes.getNamedItem("type") !== null &&
                link.attributes.getNamedItem("href") !== null) {
                var type = link.attributes.getNamedItem("type").value;
                
                if (type == "application/rss+xml" ||
                    type == "application/atom+xml" ||
                    type == "text/xml" ||
                    type == "application/feed+json" ||
                    type == "application/json") {
                    var href  = link.attributes.getNamedItem("href").value,
                        type  = typeFromString(type),
                        title;

                    if (link.attributes.getNamedItem("title") !== null) {
                        title = link.attributes.getNamedItem("title").value;
                    }
                    
                    if (!title) {
                        title = titleFromType(type);
                    }
                    
                    if (href) {
                        feeds.push({url: _fullUrl(href), title: title, type: type});
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
    var type,
        types = {
        "rss" : "RSS",
        "atom": "Atom",
        "json": "JSON",
    };
    
    for (var key in types) {
        if (string.indexOf(key) != -1) {
            type = types[key];
        }
    }
    
    if (!type) {
        type = "Unknown";
    }
    
    return type;
}

function titleFromType(type) {
    var title,
        types = {
        "RSS" : "RSS Feed",
        "Atom": "Atom Feed",
        "JSON": "JSON Feed",
    };
    
    for (var key in types) {
        if (type.indexOf(key) != -1) {
            title = types[key];
        }
    }
    
    if (!title) {
        title = "Unknown Feed";
    }
    
    return title;
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
