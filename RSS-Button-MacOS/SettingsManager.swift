//
//  SettingsManager.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-29.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Foundation
import Cocoa

class SettingsManager {
    
    static let shared = SettingsManager()
    
    let sharedUserDefaults = UserDefaults(suiteName: Bundle.main.infoDictionary!["App group"] as? String)!
    let feedHandlerKey = "feedHandler"
    let defaultFeedHandlers: [FeedHandlerModel]
    let badgeButtonKey = "badgeButtonState"
    let unsupportedHandlers = [
        "com.newsbar-app",
        "org.mozilla.thunderbird",
        "com.mentalfaculty.cream.mac",
        "com.reederapp.rkit2.mac",     // Reeder v3
    ]
    
    init() {
        self.defaultFeedHandlers = [
            FeedHandlerModel(title: "None", // Previously "Default"
                             type: FeedHandlerType.none,
                             url: nil,
                             appId: nil),
            FeedHandlerModel(title: "Copy to Clipboard",
                             type: FeedHandlerType.copy,
                             url: "%@",
                             appId: nil),
            FeedHandlerModel(title: "Feedbin",
                             type: FeedHandlerType.web,
                             url: "https://feedbin.com/?subscribe=%@",
                             appId: nil),
            FeedHandlerModel(title: "Feedly",
                             type: FeedHandlerType.web,
                             url: "https://feedly.com/i/subscription/feed/%@",
                             appId: nil),
            FeedHandlerModel(title: "Feeder",
                            type: FeedHandlerType.web,
                            url: "https://feeder.co/settings/feeds/new?q=%@",
                            appId: nil),
            FeedHandlerModel(title: "Feed HQ",
                             type: FeedHandlerType.web,
                             url: "https://feedhq.org/feed/add/?feed=%@",
                             appId: nil),
            FeedHandlerModel(title: "Feed Wrangler",
                             type: FeedHandlerType.web,
                             url: "https://feedwrangler.net/feeds/bookmarklet?feed_url=%@",
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
        
        //#if DEBUG
        //sharedUserDefaults.removeObject(forKey: feedHandlerKey)
        //sharedUserDefaults.synchronize()
        //#endif
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
    
    func setFeedHandler(_ feedHandler: FeedHandlerModel) -> Void {
        self.feedHandler = feedHandler
        
        #if DEBUG
        NSLog("Info: feedHandler set (\(feedHandler.title))")
        #endif
    }
    
    func getFeedHandler() -> FeedHandlerModel {
        return self.feedHandler
    }
    
    func setBadgeButtonState(_ enabled: Bool) -> Void {
        self.badgeButtonState = enabled
        
        #if DEBUG
        NSLog("Info: badgeButtonState set (\(enabled))")
        #endif
    }
    
    func getBadgeButtonState() -> Bool {
        return self.badgeButtonState
    }
    
    func isFeedHandlerSet() -> Bool {
        let title = self.feedHandler.title
        let type  = self.feedHandler.type
        let appId = self.feedHandler.appId
        
        return type == FeedHandlerType.none ||
            type == FeedHandlerType.app && appId == "com.apple.news" ||
            type == FeedHandlerType.web && (title == "None" || title == "Default") ? false : true
    }
    
    func isSupportedFeedHandler() -> Bool {
        let type  = self.feedHandler.type
        let appId = self.feedHandler.appId
        
        return type == FeedHandlerType.app && self.unsupportedHandlers.contains(appId!) ? false : true
    }
    
    @objc func launchApplication(bundleIdentifier: String = "com.bitpiston.RSSButton4Safari") -> Void {
        if #available(OSX 10.15, *) {
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else { return }
            NSWorkspace.shared.openApplication(at: url,
                                               configuration: NSWorkspace.OpenConfiguration(),
                                               completionHandler: nil)
        } else {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleIdentifier,
                                                 options: NSWorkspace.LaunchOptions.default,
                                                 additionalEventParamDescriptor: nil,
                                                 launchIdentifier: nil)
        }
    }
    
    @objc func noFeedHandlerConfiguredAlert(fromExtension: Bool = false) -> Void {
        let alert = NSAlert()
        alert.messageText = "No news reader configured"
        if fromExtension {
            alert.informativeText = "You must choose a news reader from within the RSS Button for Safari application to subscribe to feeds."
        } else {
            alert.informativeText = "You must choose a news reader to subscribe to feeds."
        }
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        NSLog("Error: No news reader configured")
        
        if fromExtension {
            self.launchApplication()
        }
    }
    
    @objc func noFeedHandlersAlert(fromExtension: Bool = false) -> Void {
        let alert = NSAlert()
        alert.messageText = "No news reader available"
        if fromExtension {
            alert.informativeText = "Subscribing to feeds requires a news reader with RSS support for MacOS. Please install one or if you prefer choose a web news service within the RSS Button for Safari application."
        } else {
            alert.informativeText = "Subscribing to feeds requires a news reader with RSS support for MacOS. Please install one or if you prefer choose a web based news service."
        }
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        NSLog("Error: No news reader avaiable")
        
        if fromExtension {
            self.launchApplication()
        }
    }
    
    @objc func unsupportedFeedHandlerAlert(withFeedUrl feedUrl: String?) -> Void {
        let appName = self.feedHandler.title
        let alert = NSAlert()
        var message = "\(appName) currently does not support opening feeds automatically. You will need to choose the copy to clipboard option in the RSS Button for Safari application and manually subscribe to feeds from within \(appName)."
        if feedUrl != nil {
            message = message + "\n\nYou can also copy and paste the URL below:\n\n\(feedUrl!)"
            alert.messageText = "\(appName) is unable to open the feed"
        } else {
            alert.messageText = "\(appName) does not support opening feeds"
        }
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        NSLog("Error: Attempted to open a feed with \(appName) which is bugged")
        
        if feedUrl != nil {
            self.launchApplication()
        }
    }
}
