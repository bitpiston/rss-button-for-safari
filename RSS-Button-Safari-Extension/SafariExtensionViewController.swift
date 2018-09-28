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
        DispatchQueue.main.async {
            shared.feeds = feeds
            
            //shared.tableView.sizeToFit()
            shared.tableView.reloadData()
            
            //shared.updatePreferredContentSize(updatingFeeds: true)
        }
    }
    
    @objc func subscribeButtonClick(_ sender: NSButton) {
        let row = self.tableView.row(for: sender)
        
        if let url = URL(string: "feed:" + feeds[row].url) {
            NSWorkspace.shared.open(url)
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
            cellView.detailsTextField.stringValue = "(\(feeds[row].type)) " + feeds[row].url
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
