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
    
    static let shared = SafariExtensionStateManager()
    
    var feeds: [Int: [FeedModel]] = [:]
    
    func setFeeds(hash: Int, feeds: [FeedModel]) -> Void {
        self.feeds[hash] = feeds
    }
    
    func getFeeds(hash: Int) -> [FeedModel] {
        return self.feeds[hash] ?? [FeedModel]()
    }
    
    func hasFeeds(hash: Int) -> Bool {
        return self.feeds[hash]?.isEmpty ?? true ? false : true
    }
    
    func countFeeds(hash: Int) -> Int {
        return self.feeds[hash]?.count ?? 0
    }
    
}
