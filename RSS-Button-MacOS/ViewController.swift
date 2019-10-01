//
//  ViewController.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Cocoa
import SafariServices

class ViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var informationTextField: NSTextField!
    @IBOutlet weak var enableButton: NSButton!
    @IBOutlet weak var readerPopUpButton: NSPopUpButton!
    @IBOutlet weak var badgeButtonToggle: NSButton!
    
    var feedHandlers    = [FeedHandlerModel]()
    
    let extensionId     = (Bundle.main.infoDictionary!["Extension bundle identifier"] as? String)!
    let settingsManager = SettingsManager.shared
    
    //static let shared = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkExtensionState()
        updateFeedHandlers()
        updateSettings()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        checkExtensionState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.delegate = self
        view.window!.styleMask.remove(.resizable)
        
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(checkExtensionState),
                             userInfo: nil,
                             repeats: true)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func checkExtensionState() -> Void {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionId) { [weak self] (state, error) in
            DispatchQueue.main.async {
                if let status = state?.isEnabled {
                    self?.statusTextField.textColor = status ? .systemGreen : .systemRed
                    self?.statusTextField.stringValue = status ? "● Enabled" : "● Disabled"
                    self?.informationTextField.stringValue = status ? "The extension is enabled. You can add the RSS Button to the Safari toolbar by right clicking and choosing Customize Toolbar." : "The extension is currently disabled. Please enable it from Safari preferences under the extensions tab."
                    //self?.enableButton.isHidden = status
                }
            }
        }
    }
    
    func updateFeedHandlers() -> Void {
        DispatchQueue.main.async {
            self.feedHandlers = self.settingsManager.defaultFeedHandlers
            
            // Sandboxed applications do not have access to launch services to set the default application so
            // we will have to launch apps directly
            if let foundFeedHandlers = LSCopyAllHandlersForURLScheme("feed" as CFString)?.takeRetainedValue() {
                let identifiers = foundFeedHandlers as! [String]
                
                for (index, id) in identifiers.enumerated() {
                    if id == "com.apple.news" { continue }
                    // Make sure the application exists as old cruft can remain in launch services
                    guard let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: id) else {
                        #if DEBUG
                        NSLog("Info: bad feed handler with no path detected and skipped (\(id))")
                        #endif
                        continue
                    }
                    
                    if FileManager.default.fileExists(atPath: path) {
                        let name = FileManager.default.displayName(atPath: path)
                        //let bundle = Bundle(path: path)
                        //let bundleName = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                        //let version = bundle?.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                        self.feedHandlers.insert(FeedHandlerModel(title: name,
                                                                  type: FeedHandlerType.app,
                                                                  url: "feed:%@",
                                                                  appId: id), at: 0 + index)
                        #if DEBUG
                        NSLog("Info: found valid feed handler (\(id))")
                        #endif
                    }
                    
                    #if DEBUG
                    if !FileManager.default.fileExists(atPath: path) {
                        NSLog("Info: bad feed handler that does not exist detected and skipped (\(id))")
                    }
                    #endif
                }
            }
            
            let readerMenu = NSMenu()
            readerMenu.addItem(withTitle: "None Selected", action: nil, keyEquivalent: "")
            
            for type in FeedHandlerType.allCases {
                readerMenu.addItem(NSMenuItem.separator())
                
                for handler in self.feedHandlers.filter({$0.type == type}) {
                    if handler.type == FeedHandlerType.web && (handler.title == "None" || handler.title == "Default") { continue }
                    
                    readerMenu.addItem(withTitle: handler.title, action: nil, keyEquivalent: "")
                }
            }
            
            self.readerPopUpButton.menu = readerMenu
            
            let defaultFeedHandler = LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeRetainedValue()
            let feedHandler = self.settingsManager.getFeedHandler()
            
            #if DEBUG
            NSLog("Info: default feed handler from launch services (\(String(describing: defaultFeedHandler)))")
            NSLog("Info: Saved feed handler from preferences (\(String(describing: feedHandler.title)), \(String(describing: feedHandler.appId)))")
            #endif
            
            // Set the default feed handler if none already selected unless apple news
            if !self.settingsManager.isFeedHandlerSet() {
                if defaultFeedHandler != nil && defaultFeedHandler! as String != "com.apple.news",
                    let feedHandlerToSet = self.feedHandlers.first(where: {$0.appId == defaultFeedHandler! as String}) {
                    if self.settingsManager.isSupportedFeedHandler() {
                        self.readerPopUpButton.selectItem(withTitle: feedHandlerToSet.title)
                        self.settingsManager.setFeedHandler(feedHandler: feedHandlerToSet)
                    }
                } else {
                    if self.feedHandlers.filter({$0.type == FeedHandlerType.app}).count > 0 {
                        self.settingsManager.noFeedHandlerConfiguredAlert()
                    } else {
                        self.settingsManager.noFeedHandlersAlert()
                    }
                }
            } else {
                self.readerPopUpButton.selectItem(withTitle: feedHandler.title)
            }
        }
    }
    
    func updateSettings() -> Void {
        if self.settingsManager.getBadgeButtonState() {
            self.badgeButtonToggle.state = NSControl.StateValue.on
        } else {
            self.badgeButtonToggle.state = NSControl.StateValue.off
        }
    }
    
    @IBAction func readerPopUpButtonSelected(_ sender: NSMenuItem) {
        if let feedHandler = self.feedHandlers.first(where: {$0.title == sender.title}) {
            self.settingsManager.setFeedHandler(feedHandler: feedHandler)
            
            if !self.settingsManager.isSupportedFeedHandler() {
                self.settingsManager.unsupportedFeedHandlerAlert(withFeedUrl: nil)
            }
        } else {
            self.settingsManager.setFeedHandler(feedHandler: self.settingsManager.defaultFeedHandlers[0])
        }
    }
    
    @IBAction func enableButtonClicked(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionId)
    }
    
    @IBAction func badgeButtonToggleClicked(_ sender: NSButton) {
        let value = sender.state.rawValue == 0 ? false : true
        
        self.settingsManager.setBadgeButtonState(enabled: value)
    }
}
