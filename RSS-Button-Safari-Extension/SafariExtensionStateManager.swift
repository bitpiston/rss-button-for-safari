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
    
    private var feeds: [Int: [FeedModel]] = [:]
    
    func setFeeds(hash: Int, feeds: [FeedModel]) -> Void {
        self.queue.async(flags: .barrier) {
             self.feeds[hash] = feeds
        }
    }
    
    func getFeeds(hash: Int) -> [FeedModel] {
        var result: [FeedModel]?
        
        self.queue.sync {
            result = self.feeds[hash]
        }
        
        return result ?? [FeedModel]()
    }
    
    func hasFeeds(hash: Int) -> Bool {
        var result: Bool?
        
        self.queue.sync {
            result = self.feeds[hash]?.isEmpty
        }
        
        return result ?? true ? false : true
    }
    
    func countFeeds(hash: Int) -> Int {
        var result: Int?
        
        self.queue.sync {
            result = self.feeds[hash]?.count
        }
        
        return result ?? 0
    }
    
}
