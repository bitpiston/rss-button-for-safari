//
//  SafariExtensionHandler.swift
//  RSS Button
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    typealias FeedDictionary = [String: Any]
    
    let stateManager = SafariExtensionStateManager.shared
    let viewController = SafariExtensionViewController.shared
    let settingsManager = SettingsManager.shared
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        page.getPropertiesWithCompletionHandler { properties in
            #if DEBUG
            NSLog("Info: The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            #endif
            
            switch messageName {
            case "extractedFeeds":
                guard let url: URL = properties?.url else { return }
                let feeds = self.decodeJSONFeeds(data: userInfo?["feeds"] as? [FeedDictionary])
                
                if !feeds.isEmpty {
                    self.stateManager.setFeeds(url: url, feeds: feeds)
                    SFSafariApplication.setToolbarItemsNeedUpdate()
                }
                
            default:
                NSLog("Error: Unhandled message received")
            }
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        getActivePageProperties {
            if let url: URL = $0?.url {
                let feedCount  = self.stateManager.countFeeds(url: url)
                let feedsFound = feedCount > 0 ? true : false
                let badgeText  = self.settingsManager.getBadgeButtonState() && feedsFound ? String(feedCount) : ""
                
                #if DEBUG
                NSLog("Info: validateToolbarItem (\(url)) with feedsFound (\(feedsFound))")
                NSLog("Info: SafariExtensionStateManager feeds stored for \(self.stateManager.feeds.count) pages")
                #endif
                
                validationHandler(feedsFound, badgeText)
            } else {
                validationHandler(false, "")
            }
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return viewController
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        getActivePageProperties {
            guard let url = $0?.url else { return }
            let feeds = self.stateManager.getFeeds(url: url) 
            
            #if DEBUG
            NSLog("Info: popoverWillShow (\(url)) with \(feeds.count) feeds (\(feeds))")
            #endif
            
            self.viewController.updateFeeds(with: feeds)
        }
    }
    
    func decodeJSONFeeds(data: [FeedDictionary]?) -> [FeedModel] {
        var feeds = [FeedModel]()
        
        if data != nil {
            for (index, values) in data!.enumerated() {
                if values["title"] == nil || values["type"] == nil || values["url"] == nil { continue }
                
                let feed = FeedModel(title: values["title"] as! String,
                                     type : values["type"]  as! String,
                                     url  : values["url"]   as! String)
                
                feeds.insert(feed, at: index)
            }
        }
        
        return feeds
    }
    
    func getActivePage(completionHandler: @escaping (SFSafariPage?) -> Void) {
        SFSafariApplication.getActiveWindow {
            $0?.getActiveTab {
                $0?.getActivePage(completionHandler: completionHandler)
            }
        }
    }
    
    func getActivePageProperties(completionHandler: @escaping (SFSafariPageProperties?) -> Void) {
        getActivePage {
            $0?.getPropertiesWithCompletionHandler(completionHandler)
        }
    }
    
    //func getActiveTab(completionHandler: @escaping (SFSafariTab?) -> Void) {
    //    SFSafariApplication.getActiveWindow {
    //        $0?.getActiveTab(completionHandler: completionHandler)
    //    }
    //}
    
    //func getActiveWindow(completionHandler: @escaping (SFSafariWindow?) -> Void) {
    //    SFSafariApplication.getActiveWindow(completionHandler: completionHandler)
    //}
    
}
