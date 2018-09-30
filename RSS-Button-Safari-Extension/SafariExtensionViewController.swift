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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.preferredContentSize = CGSize(width: 310, height: 75)
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
            
            //shared.tableView.sizeToFit()
            self.tableView.reloadData()
            //self.updatePreferredContentSize(updatingFeeds: true)
        }
    }
    
    @objc func subscribeButtonClick(_ sender: NSButton) {
        let row = self.tableView.row(for: sender)
        let feedHandler: FeedHandlerModel = self.settingsManager.feedHandler

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
        return self.feeds.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard self.feeds.count > row else {
            return nil
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cellIdentifier")
        
        if let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? FeedTableCellView {
            cellView.titleTextField.stringValue = self.feeds[row].title
            cellView.detailsTextField.stringValue = {
                if self.showFeedType == true {
                    return "(\(self.feeds[row].type)) " + self.feeds[row].url
                } else {
                    return self.feeds[row].url
                }
            }()
            cellView.subscribeButton.target = self
            cellView.subscribeButton.action = #selector(self.subscribeButtonClick(_:))
            
            self.maxCellWidth = max(self.maxCellWidth, cellView.fittingSize.width)
            
            if row == self.feeds.count - 1 {
                self.updatePreferredContentSize()
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
