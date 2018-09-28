//
//  SafariExtensionViewController.swift
//  RSS Button
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import SafariServices
import Cocoa

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var feeds = [FeedModel]()
    var contentWidth: CGFloat = 0
    var maxCellWidth: CGFloat = 0
    var showFeedType: Bool = false
    let feedHandlerAppId = LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeUnretainedValue() as String?
    
    static let shared = SafariExtensionViewController()
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.preferredContentSize = CGSize(width: 310, height: 75)
        
        super.viewDidLoad()
    }
    
    func updatePreferredContentSize(updatingFeeds: Bool = false) {
        if updatingFeeds == true {
            //self.tableView.needsLayout = true
            self.tableView.layoutSubtreeIfNeeded()
        } else {
            self.contentWidth = self.maxCellWidth
            self.maxCellWidth = 0
        }
        
        let width: CGFloat = min(max(self.contentWidth, 310), 410)
        let height: CGFloat = self.tableView.fittingSize.height + 30
        
        self.preferredContentSize = CGSize(width: width, height: height)
    }
    
    static func updateFeeds(with feeds: [FeedModel]) {
        let rssFeed: Bool     = feeds.contains(where: { $0.type == "RSS" })
        let atomFeed: Bool    = feeds.contains(where: { $0.type == "Atom" })
        let unknownFeed: Bool = feeds.contains(where: { $0.type == "Unknown" })
        
        DispatchQueue.main.async {
            shared.feeds = feeds
            
            if (rssFeed == true && atomFeed == true) || unknownFeed == true {
                shared.showFeedType = true
            } else {
                shared.showFeedType = false
            }
            
            //shared.tableView.sizeToFit()
            shared.tableView.reloadData()
            
            //shared.updatePreferredContentSize(updatingFeeds: true)
        }
    }
    
    @objc func subscribeButtonClick(_ sender: NSButton) {
        let row = self.tableView.row(for: sender)
        
        if let url = URL(string: "feed:" + feeds[row].url) {
            #if DEBUG
            NSLog("Info: Opening feed (\(url))")
            #endif
            
            NSWorkspace.shared.open(url)
        } else {
            NSLog("Error: Unhandled URL for feed")
        }
        
/*
        switch self.feedHandler.type {
            case "app":
                if self.feedHandler.value != nil, let url = URL(string: feeds[row].url) {
                    #if DEBUG
                    NSLog("Info: Opening feed (\(url)) with \(self.feedHandler.value)")
                    #endif

                    NSWorkspace.shared.open([url],
                                            withAppBundleIdentifier: self.feedHandlerAppId!,
                                            options: NSWorkspace.LaunchOptions.default,
                                            additionalEventParamDescriptor: nil,
                                            launchIdentifiers: nil)
                } else {
                    NSLog("Error: Unhandled URL for feed via application (\(self.feedHandler.value))")
                }
            case "web":
                if self.feedHandler.value != nil, let url = URL(string: feeds[row].url) {
                    // needs to construct a url replacing %s in feedHandler.value with feed.url
                    #if DEBUG
                    NSLog("Info: Opening feed (\(url)) with \(self.feedHandlerAppId!)")
                    #endif

                    NSWorkspace.shared.open(url)
                } else {
                    NSLog("Error: Unhandled URL for feed via web (\(self.feedHandler.value))")
                }
            default:
                if let url = URL(string: "feed:" + feeds[row].url) {
                    // this could probably be merged with web and replace %s on feed:%s
                    #if DEBUG
                    NSLog("Info: Opening \(url) with default application)")
                    #endif

                    NSWorkspace.shared.open(url)
                } else {
                    NSLog("Error: Unhandled URL for feed via default application")
                }
        }
         
        if self.feedHandlerAppId != nil, let url = URL(string: feeds[row].url) {
            #if DEBUG
            NSLog("Info: Opening feed (\(url)) with \(self.feedHandlerAppId!)")
            #endif
            
            NSWorkspace.shared.open([url],
                                    //withAppBundleIdentifier: self.feedHandlerAppId!,
                                    withAppBundleIdentifier: "com.reederapp.mac",
                                    options: NSWorkspace.LaunchOptions.default,
                                    additionalEventParamDescriptor: nil,
                                    launchIdentifiers: nil)
        } else if let url = URL(string: "feed:" + feeds[row].url) {
            #if DEBUG
            NSLog("Info: Opening \(url) with default application)")
            #endif
            
            NSWorkspace.shared.open(url)
        } else {
            NSLog("Error: Unhandled URL for feed")
        }
*/
    }
    
}

extension SafariExtensionViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard feeds.count > row else {
            return nil
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cellIdentifier")
        
        if let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? FeedTableCellView {
            cellView.titleTextField.stringValue = feeds[row].title
            cellView.detailsTextField.stringValue = {
                if showFeedType {
                    return "(\(feeds[row].type)) " + feeds[row].url
                } else {
                    return feeds[row].url
                }
            }()
            cellView.subscribeButton.target = self
            cellView.subscribeButton.action = #selector(self.subscribeButtonClick(_:))
            
            maxCellWidth = max(maxCellWidth, cellView.fittingSize.width)
            
            if row == feeds.count - 1 {
                updatePreferredContentSize()
            }
            
            return cellView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
}

class FeedTableCellView: NSTableCellView {
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var detailsTextField: NSTextField!
    @IBOutlet weak var subscribeButton: NSButton!
    
}
