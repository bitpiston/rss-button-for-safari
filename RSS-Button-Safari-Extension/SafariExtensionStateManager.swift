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
    
    func setFeeds(url: URL, feeds: [FeedModel]) -> Void {
        self.feeds[url] = feeds
    }
    
    func getFeeds(url: URL) -> [FeedModel] {
        return self.feeds[url] ?? [FeedModel]()
    }
    
    func hasFeeds(url: URL) -> Bool {
        return self.feeds[url]?.isEmpty ?? true ? false : true
    }
    
}
