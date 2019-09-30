//
//  SettingsManager.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-29.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Foundation

class SettingsManager {
    
    static let shared = SettingsManager()
    
    let sharedUserDefaults = UserDefaults(suiteName: Bundle.main.infoDictionary!["App group"] as? String)!
    let feedHandlerKey = "feedHandler"
    let defaultFeedHandlers: [FeedHandlerModel]
    let badgeButtonKey = "badgeButtonState"
    
    init() {
        self.defaultFeedHandlers = [
            FeedHandlerModel(title: "Default",
                             type: FeedHandlerType.web,
                             url: "feed:%@",
                             appId: nil),
            FeedHandlerModel(title: "Feedbin",
                             type: FeedHandlerType.web,
                             url: "https://feedbin.com/?subscribe=%@",
                             appId: nil),
            FeedHandlerModel(title: "Feedly",
                             type: FeedHandlerType.web,
                             url: "https://feedly.com/i/subscription/feed/%@",
                             appId: nil),
            FeedHandlerModel(title: "Feed HQ",
                             type: FeedHandlerType.web,
                             url: "https://feedhq.org/feed/add/?feed=%@",
                             appId: nil),
            FeedHandlerModel(title: "NewsBlur",
                             type: FeedHandlerType.web,
                             url: "https://www.newsblur.com/?url=%@",
                             appId: nil),
            FeedHandlerModel(title: "The Old Reader",
                             type: FeedHandlerType.web,
                             url: "https://theoldreader.com/feeds/subscribe?url=%@",
                             appId: nil),
            FeedHandlerModel(title: "Inoreader",
                             type: FeedHandlerType.web,
                             url: "https://www.inoreader.com/?add_feed=%@",
                             appId: nil),
            FeedHandlerModel(title: "Minimal Reader",
                             type: FeedHandlerType.web,
                             url: "https://minimalreader.com/settings/subscriptions/add?url=%@",
                             appId: nil),
            FeedHandlerModel(title: "BazQuz Reader",
                             type: FeedHandlerType.web,
                             url: "https://bazqux.com/add?url=%@",
                             appId: nil)
        ]
        
        //sharedUserDefaults.removeObject(forKey: feedHandlerKey)
        //sharedUserDefaults.synchronize()
    }
    
    var feedHandler: FeedHandlerModel {
        get {
            if let data = sharedUserDefaults.value(forKey: feedHandlerKey) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as! FeedHandlerModel
            } else {
                return defaultFeedHandlers[0]
            }
        }
        set(value) {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            sharedUserDefaults.set(data, forKey: feedHandlerKey)
            sharedUserDefaults.synchronize()
        }
    }
    
    var badgeButtonState: Bool {
        get {
            return sharedUserDefaults.value(forKey: badgeButtonKey) as? Bool ?? false
        }
        set(value) {
            sharedUserDefaults.set(value, forKey: badgeButtonKey)
        }
    }
    
    func setFeedHandler(feedHandler: FeedHandlerModel) -> Void {
        self.feedHandler = feedHandler
        
        #if DEBUG
        NSLog("Info: feedHandler set (\(feedHandler.title))")
        #endif
    }
    
    func getFeedHandler() -> FeedHandlerModel {
        return self.feedHandler
    }
    
    func setBadgeButtonState(enabled: Bool) -> Void {
        self.badgeButtonState = enabled
        
        #if DEBUG
        NSLog("Info: badgeButtonState set (\(enabled))")
        #endif
    }
    
    func getBadgeButtonState() -> Bool {
        return self.badgeButtonState
    }
}
