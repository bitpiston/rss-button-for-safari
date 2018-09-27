//
//  SafariExtensionStateManager.swift
//  RSS Button
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import SafariServices

class SafariExtensionStateManager {
    
    static let shared = SafariExtensionStateManager()
    
    var feeds: [URL: [FeedModel]] = [:]
    
    static func setFeeds(url: URL, feeds: [FeedModel]) -> Void {
        shared.feeds[url] = feeds
    }
    
    static func getFeeds(url: URL) -> [FeedModel] {
        return shared.feeds[url] ?? [FeedModel]()
    }
    
    static func hasFeeds(url: URL) -> Bool {
        return shared.feeds[url]?.isEmpty ?? true ? false : true
    }
    
}
