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
                guard userInfo?["feeds"] != nil else { return }
                
                let feeds = self.decodeJSONFeeds(data: userInfo!["feeds"] as? [FeedDictionary])
                
                if !feeds.isEmpty {
                    self.stateManager.setFeeds(hash: page.hash, feeds: feeds)
                    SFSafariApplication.setToolbarItemsNeedUpdate()
                }
                
            default:
                NSLog("Error: Unhandled message received in \(page.description)")
            }
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        window.getActiveTab { tab in
            guard let tab = tab else {
                #if DEBUG
                NSLog("Info: Failed to get active tab \(window.description)")
                #endif
                validationHandler(false, "")
                return
            }
            
            tab.getActivePage(completionHandler: { page in
                guard let page = page else {
                    #if DEBUG
                    NSLog("Info: Failed to get active page \(tab.description)")
                    #endif
                    validationHandler(false, "")
                    return
                }
                
                page.getPropertiesWithCompletionHandler { properties in
                    guard let properties = properties else {
                        #if DEBUG
                        NSLog("Info: Failed to get page properties in \(page.description)")
                        #endif
                        validationHandler(false, "")
                        return
                    }
                    
                    guard let url = properties.url,
                        url.scheme == "http" || url.scheme == "https" else {
                        #if DEBUG
                        NSLog("Info: Failed to get valid url from page properties in \(page.description)")
                        #endif
                        validationHandler(false, "")
                        return
                    }
                
                    let feedCount  = self.stateManager.countFeeds(hash: page.hash)
                    let feedsFound = feedCount > 0 ? true : false
                    let badgeText  = self.settingsManager.getBadgeButtonState() && feedsFound ? String(feedCount) : ""
                    
                    #if DEBUG
                    NSLog("Info: validateToolbarItem (\(url), \(page.hash)) with feedsFound (\(feedsFound))")
                    NSLog("Info: SafariExtensionStateManager feeds stored for \(self.stateManager.feeds.count) pages")
                    #endif
                    
                    validationHandler(feedsFound, badgeText)
                }
            })
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return viewController
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        window.getActiveTab { tab in
            guard let tab = tab else {
                #if DEBUG
                NSLog("Info: Failed to get active tab \(window.description)")
                #endif
                return
            }
            
            tab.getActivePage(completionHandler: { page in
                guard let page = page else {
                    #if DEBUG
                    NSLog("Info: Failed to get active page \(tab.description)")
                    #endif
                    return
                }
                
                page.getPropertiesWithCompletionHandler { properties in
                    guard let properties = properties else {
                        #if DEBUG
                        NSLog("Info: Failed to get page properties in \(page.description)")
                        #endif
                        return
                    }
                    
                    guard let url = properties.url,
                        url.scheme == "http" || url.scheme == "https" else {
                        #if DEBUG
                        NSLog("Info: Failed to get valid url from page properties in \(page.description)")
                        #endif
                        return
                    }
                    
                    let feeds = self.stateManager.getFeeds(hash: page.hash)
                    
                    #if DEBUG
                    NSLog("Info: popoverWillShow (\(url), \(page.hash)) with \(feeds.count) feeds (\(feeds))")
                    #endif
                    
                    self.viewController.updateFeeds(with: feeds)
                }
            })
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
    
}
