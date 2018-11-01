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
    
    var feedHandlers = [FeedHandlerModel]()
    let extensionId = (Bundle.main.infoDictionary!["Extension bundle identifier"] as? String)!
    
    let settingsManager = SettingsManager.shared
    
    //static let shared = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkExtensionState()
        updateFeedHandlers()
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
            
            // Sandboxed applications do not have access to launch services to set the default scheme so
            // unless that changes in the future listing all installed feed readers to choose from is moot.
            if let foundFeedHandlers = LSCopyAllHandlersForURLScheme("feed" as CFString)?.takeUnretainedValue() {
                let identifiers = foundFeedHandlers as! [String]
                
                for (index, id) in identifiers.enumerated() {
                    if id == "com.apple.news" { continue }
                    
                    let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: id)
                    let name = FileManager.default.displayName(atPath: path!)
                    self.feedHandlers.insert(FeedHandlerModel(title: name,
                                                              type: FeedHandlerType.app,
                                                              url: "feed:%@",
                                                              appId: id), at: 0 + index)
                }
            }
            
            let defaultFeedHandler = LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeUnretainedValue()
            
            // Display the default news reader by name if available and supported
            /*
            if defaultFeedHandler != nil, defaultFeedHandler! as String != "com.apple.news" {
                let id = defaultFeedHandler! as String
                let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: id)
                let name = FileManager.default.displayName(atPath: path!)
                self.feedHandlers.insert(FeedHandlerModel(title: name,
                                                          type: FeedHandlerType.app,
                                                          url: "feed:%@",
                                                          appId: id), at: 1)
            }
            */
            
            self.readerPopUpButton.removeAllItems()
            
            for handler in self.feedHandlers {
                if handler.title == "Default" { continue }
                self.readerPopUpButton.addItem(withTitle: handler.title)
            }
            
            let feedHandler = self.settingsManager.feedHandler
            
            // Warn if no supported news reader is available
            //if feedHandler.type == FeedHandlerType.app || feedHandler.title == "Default",
            //    defaultFeedHandler == nil || defaultFeedHandler! as String == "com.apple.news" {
            if feedHandler.type == FeedHandlerType.app && feedHandler.appId == "com.apple.news" ||
                feedHandler.title == "Default" && defaultFeedHandler! as String == "com.apple.news" {
                self.readerPopUpButton.selectItem(at: -1)
                self.unsupportedFeedHandlerAlert()
            } else {
                if feedHandler.title == "Default" {
                    self.readerPopUpButton.selectItem(at: 0)
                } else {
                    self.readerPopUpButton.selectItem(withTitle: feedHandler.title)
                }
            }
        }
    }
    
    func unsupportedFeedHandlerAlert() -> Void {
        let alert = NSAlert()
        alert.messageText = "No default news reader available!"
        alert.informativeText = "Subscribing to feeds requires a news reader with RSS support. Please install one or sign up for a web based news service."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSLog("Error: No news reader supporting RSS or Atom feeds avaiable")
    }
    
    @IBAction func readerPopUpButtonSelected(_ sender: NSMenuItem) {
        if let feedHandler = feedHandlers.first(where: {$0.title == sender.title}) {
            settingsManager.feedHandler = feedHandler
            
            /*
            // Sandboxed applications do not have access to launch services to set the default scheme so
            // unless that changes in the future listing all installed feed readers to choose from is moot.
            if feedHandler.type == FeedHandlerType.app {
                let retval = LSSetDefaultHandlerForURLScheme("feed" as CFString, feedHandler.appId! as CFString)
                if retval != 0 {
                    NSLog("Debug: Failed to set default URL Scheme for news reader.")
                }
            }
            */
            
            #if DEBUG
            NSLog("Info: feedHandler set (\(settingsManager.feedHandler.title))")
            #endif
        }
    }
    
    @IBAction func enableButtonClicked(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionId)
    }
    
}
