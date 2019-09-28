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
    
    let settingsManager = SettingsManager.shared
    
    static let shared = SafariExtensionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        preferredContentSize = CGSize(width: 310, height: 75)
    }
    
    func updatePreferredContentSize() -> Void {
        contentWidth = maxCellWidth
        maxCellWidth = 0
        
        let width: CGFloat = min(max(contentWidth, 310), 410)
        let height: CGFloat = tableView.fittingSize.height + 30
        
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    func updateFeeds(with feeds: [FeedModel]) -> Void {
        let rssFeed: Bool     = feeds.contains(where: { $0.type == "RSS" })
        let atomFeed: Bool    = feeds.contains(where: { $0.type == "Atom" })
        let jsonFeed: Bool    = feeds.contains(where: { $0.type == "JSON" })
        let unknownFeed: Bool = feeds.contains(where: { $0.type == "Unknown" })
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.feeds = feeds
            
            if (rssFeed == true && atomFeed == true) || (rssFeed == true && jsonFeed == true)
                || (atomFeed == true && jsonFeed == true) || unknownFeed == true {
                self.showFeedType = true
            } else {
                self.showFeedType = false
            }
            
            //self.tableView.sizeToFit()
            self.tableView.reloadData()
        }
    }
    
    @objc func subscribeButtonClicked(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        let feedHandler = settingsManager.feedHandler
        let feedUrl = feeds[row].url
        
        #if DEBUG
        NSLog("Info: Subscribe button clicked for feed (\(feedUrl)) with feed handler (\(String(describing: feedHandler.appId)))")
        #endif
        
        // Warn of known unsupported or bugged readers
        let unsupportedHandlers = [
            "com.reederapp.rkit2.mac", // Reeder v3
            //"com.reederapp.macos", // Reeder v4 (fixed in 4.1.5?)
            "com.mentalfaculty.cream.mac"
        ]
        if feedHandler.type == FeedHandlerType.app, unsupportedHandlers.contains(feedHandler.appId!) {
            let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: feedHandler.appId!)
            let name = FileManager.default.displayName(atPath: path!)
            unsupportedFeedHandlerAlert(withAppName: name, withFeedUrl: feedUrl)
        } else {
            if let url = URL(string: String(format: feedHandler.url!, feedUrl)) {
                #if DEBUG
                NSLog("Info: Opening feed (\(url))")
                #endif
                
                let defaultFeedHandler = LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeRetainedValue()
                
                if feedHandler.type == FeedHandlerType.app && feedHandler.appId == "com.apple.news" ||
                    feedHandler.title == "Default" && defaultFeedHandler != nil && defaultFeedHandler! as String == "com.apple.news" {
                    noAvailableFeedHandlerAlert()
                } else {
                    if feedHandler.type == FeedHandlerType.app {
                        NSWorkspace.shared.open([url], withAppBundleIdentifier: feedHandler.appId,
                                                options: NSWorkspace.LaunchOptions.default,
                                                additionalEventParamDescriptor: nil,
                                                launchIdentifiers: nil)
                    } else {
                        NSWorkspace.shared.open(url)
                    }
                }
            } else {
                NSLog("Error: Unhandled URL for feed (\(feedHandler.title))")
            }
        }
    }
    
    @objc func noAvailableFeedHandlerAlert() -> Void {
        let alert = NSAlert()
        alert.messageText = "No news reader available!"
        alert.informativeText = "Subscribing to feeds requires a news reader with RSS support. Please install one or sign up for a web based news service."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSLog("Error: No news reader supporting RSS or Atom feeds avaiable")
    }
    
    @objc func unsupportedFeedHandlerAlert(withAppName appName: String,
                                        withFeedUrl feedUrl: String) -> Void {
        let alert = NSAlert()
        alert.messageText = "\(appName) is unable to open the feed"
        alert.informativeText = "\(appName) currently does not support opening feeds automatically. You will need to manually subscribe from within \(appName).\n\nYou can copy and paste the URL below:\n\(feedUrl)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSLog("Error: Attempted to open a feed with \(appName) which is bugged")
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
                if showFeedType == true {
                    return "(\(feeds[row].type)) " + feeds[row].url
                } else {
                    return feeds[row].url
                }
            }()
            cellView.subscribeButton.target = self
            cellView.subscribeButton.action = #selector(self.subscribeButtonClicked(_:))
            
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
