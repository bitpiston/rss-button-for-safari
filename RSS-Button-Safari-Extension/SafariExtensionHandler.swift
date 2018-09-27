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
                    SafariExtensionStateManager.setFeeds(url: url, feeds: feeds)
                    SFSafariApplication.setToolbarItemsNeedUpdate()
                }
                
            default:
                NSLog("Error: Unhandled message received")
            }
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        getActivePageProperties {
            guard let url: URL = $0?.url else { return }
            let feedsFound = SafariExtensionStateManager.hasFeeds(url: url)
            
            #if DEBUG
            NSLog("Info: validateToolbarItem (\(url)) with feedsFound (\(feedsFound))")
            NSLog("Info: SafariExtensionStateManager feeds stored for \(SafariExtensionStateManager.shared.feeds.count) pages")
            #endif
            
            validationHandler(feedsFound, "")
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func popoverWillShow(in window: SFSafariWindow) {
        getActivePageProperties {
            guard let url = $0?.url else { return }
            let feeds = SafariExtensionStateManager.getFeeds(url: url)
            
            #if DEBUG
            NSLog("Info: popoverWillShow (\(url)) with \(feeds.count) feeds (\(feeds))")
            #endif
            
            SafariExtensionViewController.updateFeeds(with: feeds)
        }
    }
    
    func decodeJSONFeeds(data: [FeedDictionary]?) -> [FeedModel] {
        var feeds = [FeedModel]()
        
        if data != nil {
            for (index, values) in data!.enumerated() {
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
