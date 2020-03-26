//
//  SafariExtensionStateManager.swift
//  RSS Button
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Foundation
import SafariServices

class SafariExtensionStateManager {
    private let queue = DispatchQueue(label: "com.bitpiston.RSSButton4Safari.feedStore",
                                      attributes: .concurrent)
    
    static let shared = SafariExtensionStateManager()
    
    private var feeds: [URL: [FeedModel]] = [:]
    
    func setFeeds(url: URL, feeds: [FeedModel]) -> Void {
        self.queue.async(flags: .barrier) {
             self.feeds[url] = feeds
        }
    }
    
    func getFeeds(url: URL) -> [FeedModel] {
        var result: [FeedModel]?
        
        self.queue.sync {
            result = self.feeds[url]
        }
        
        return result ?? [FeedModel]()
    }
    
    func hasFeeds(url: URL) -> Bool {
        var result: Bool?
        
        self.queue.sync {
            result = self.feeds[url]?.isEmpty
        }
        
        return result ?? true ? false : true
    }
    
    func countFeeds(url: URL) -> Int {
        var result: Int?
        
        self.queue.sync {
            result = self.feeds[url]?.count
        }
        
        return result ?? 0
    }
    
}
