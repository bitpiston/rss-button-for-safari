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
    }
    
    var feedHandler: FeedHandlerModel {
        get {
            if let data = sharedUserDefaults.value(forKey: feedHandlerKey) as? Data {
                //NSKeyedUnarchiver.setClass(FeedHandlerModel.self, forClassName: "FeedHandlerModel")
                return NSKeyedUnarchiver.unarchiveObject(with: data) as! FeedHandlerModel
            } else {
                return self.defaultFeedHandlers[0]
            }
        }
        set(value) {
            //NSKeyedArchiver.setClassName("FeedHandlerModel", for: FeedHandlerModel.self)
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            sharedUserDefaults.set(data, forKey: feedHandlerKey)
            sharedUserDefaults.synchronize()
        }
    }
}
