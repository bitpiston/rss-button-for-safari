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
    
    func updatePreferredContentSize(updatingFeeds: Bool = false) {
        if updatingFeeds == true {
            //self.tableView.needsLayout = true
            tableView.layoutSubtreeIfNeeded()
        } else {
            contentWidth = maxCellWidth
            maxCellWidth = 0
        }
        
        let width: CGFloat = min(max(contentWidth, 310), 410)
        let height: CGFloat = tableView.fittingSize.height + 30
        
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    func updateFeeds(with feeds: [FeedModel]) {
        let rssFeed: Bool     = feeds.contains(where: { $0.type == "RSS" })
        let atomFeed: Bool    = feeds.contains(where: { $0.type == "Atom" })
        let unknownFeed: Bool = feeds.contains(where: { $0.type == "Unknown" })
        
        DispatchQueue.main.async {
            self.feeds = feeds

            if (rssFeed == true && atomFeed == true) || unknownFeed == true {
                self.showFeedType = true
            } else {
                self.showFeedType = false
            }
            
            //self.tableView.sizeToFit()
            self.tableView.reloadData()
            //self.updatePreferredContentSize(updatingFeeds: true)
        }
    }
    
    @objc func subscribeButtonClick(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        let feedHandler: FeedHandlerModel = settingsManager.feedHandler

        switch feedHandler.type {
        case FeedHandlerType.app:
            if let url = URL(string: feeds[row].url) {
                #if DEBUG
                NSLog("Info: Opening feed (\(url)) with application (\(feedHandler.title))")
                #endif

                NSWorkspace.shared.open([url],
                                        withAppBundleIdentifier: feedHandler.appId,
                                        options: NSWorkspace.LaunchOptions.default,
                                        additionalEventParamDescriptor: nil,
                                        launchIdentifiers: nil)
            } else {
                NSLog("Error: Unhandled URL for feed via application (\(feedHandler.title))")
            }
            
        case FeedHandlerType.web:
            if let url = URL(string: String(format: feedHandler.url!, feeds[row].url)) {
                #if DEBUG
                NSLog("Info: Opening feed (\(url)) with web (\(feedHandler.title))")
                #endif

                NSWorkspace.shared.open(url)
            } else {
                NSLog("Error: Unhandled URL for feed via web (\(feedHandler.title))")
            }
        }

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
