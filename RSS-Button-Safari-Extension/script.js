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

var feeds  = [],
    parsed = false,
    href   = window.location.href,
    timer  = 0;

document.addEventListener("DOMContentLoaded", function(event) {
    if (isValidPage()) {
        extractFeeds();
        
        // To handle document / url changes requires polling
        startPolling();
        
        // Don't poll if the tab is inactive
        document.addEventListener('visibilitychange', function(event) {
            if (document.hidden && timer != 0) {
                stopPolling();
                console.info('RSS Button for Safari stopped polling for changes.');
            } else {
                startPolling();
                console.info('RSS Button for Safari started polling for changes.');
            }
        });
    }
});

function isValidPage() {
    return (window.top === window &&
            typeof safari != "undefined" &&
            (document.domain !== "undefined" || document.location != null) &&
            window.location.href !== "favorites://");
}

function pollForChanges() {
    if (parsed === true && href != window.location.href) {
        stopPolling();
        
        href = window.location.href;
        parsed = false;
        
        extractFeeds();
        
        startPolling();
    } else {
        startPolling();
    }
}

function startPolling(seconds = 1) {
    timer = setTimeout(pollForChanges, seconds * 1000);
}

function stopPolling() {
    if (timer != 0) {
        clearTimeout(timer);
        timer = 0;
    }
}

function extractFeeds(setParsed = true) {
    if (parsed === true) { return };
    
    if (!feeds.length > 0) {
        var headLinks = document.querySelectorAll("link[rel='alternate']");
        // this should be "head > link[rel='alternate']" but many sites including slashdot have it in the body
        
        for (var i = 0; i < headLinks.length; i++) {
            var link = headLinks[i];
            
            if (link.attributes.getNamedItem("rel") !== null &&
                link.attributes.getNamedItem("rel").value == "alternate" &&
                link.attributes.getNamedItem("type") !== null &&
                link.attributes.getNamedItem("href") !== null) {
                var type = link.attributes.getNamedItem("type").value;
                
                if (type == "application/rss+xml" ||
                    type == "application/atom+xml" ||
                    type == "application/rdf+xml" ||
                    type == "application/xml" ||
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
                        try {
                            feeds.push({url: getUrl(href), title: title, type: type});
                        } catch (error) {
                            // Invalid URL or base URI when constructing URL() in getUrl()
                            continue;
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
        console.info('RSS Button for Safari detected ' + feeds.length + ' feed(s).');
    }
}

function typeFromString(string) {
    var type,
        types = {
        "rss" : "RSS",
        "atom": "Atom",
        "json": "JSON",
        "rdf" : "RDF",
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

function getUrl(href) {
    var base = document.baseURI;
    var url = new URL(href, base);
    
    return url.href;
}
