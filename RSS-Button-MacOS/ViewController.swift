//
//  ViewController.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Cocoa
import SafariServices

class ViewController: NSViewController, NSWindowDelegate, NSTextFieldDelegate {

    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var informationTextField: NSTextField!
    @IBOutlet weak var enableButton: NSButton!
    @IBOutlet weak var readerPopUpButton: NSPopUpButton!
    @IBOutlet weak var customUrlTextField: NSTextField!
    @IBOutlet weak var badgeButtonToggle: NSButton!
    @IBOutlet weak var customUrlTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customUrlTextFieldPaddingConstraint: NSLayoutConstraint!
   
    var feedHandlers = [FeedHandlerModel]()
    var previousCustomUrl: String?
    let customUrlTitle = "Custom URL"
    
    let extensionId = (Bundle.main.infoDictionary!["Extension bundle identifier"] as? String)!
    let settingsManager = SettingsManager.shared
    
    //static let shared = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customUrlTextField.delegate = self
        
        self.checkExtensionState()
        self.updateFeedHandlers()
        self.updateSettings()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.checkExtensionState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.delegate = self
        view.window!.styleMask.remove(.resizable)
        
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(self.checkExtensionState),
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
                } else {
                    // Error message due to failure to install?
                    self?.statusTextField.textColor = .systemRed
                    self?.statusTextField.stringValue = "● Not Installed"
                    self?.informationTextField.stringValue = "The extension is not installed. Please quit Safari, quit and move RSS Button for Safari to the trash and reinstall from the Mac App Store."
                }
            }
        }
    }
    
    func updateFeedHandlers() -> Void {
        self.feedHandlers = self.settingsManager.defaultFeedHandlers
        
        let defaultFeedHandler = LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeRetainedValue()
        let feedHandler = self.settingsManager.getFeedHandler()
        
        #if DEBUG
        NSLog("Info: default feed handler from launch services (\(String(describing: defaultFeedHandler)))")
        NSLog("Info: retrieved feed handler from preferences (\(String(describing: feedHandler.title)), \(String(describing: feedHandler.appId)))")
        #endif
        
        // Get all the applications registered as handlers for feed URLs
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
        
        // Custom URLs
        if feedHandler.type == FeedHandlerType.custom {
            self.feedHandlers.append(feedHandler)
        } else {
            self.feedHandlers.append(FeedHandlerModel(title: self.customUrlTitle,
                                                      type: FeedHandlerType.custom,
                                                      url: "https://example.com/?url=%@",
                                                      appId: nil))
        }
        
        // Create the menu of feed handlers
        let readerMenu = NSMenu()
        readerMenu.addItem(withTitle: "None Selected", action: nil, keyEquivalent: "")
        
        for type in FeedHandlerType.allCases {
            readerMenu.addItem(NSMenuItem.separator())
            
            for handler in self.feedHandlers.filter({$0.type == type}) {
                if handler.type == FeedHandlerType.none { continue }
                
                readerMenu.addItem(withTitle: handler.title, action: nil, keyEquivalent: "")
            }
        }
        
        self.readerPopUpButton.menu = readerMenu
        
        // Set the default feed handler if on first run unless apple news
        if !self.settingsManager.isFeedHandlerSet() {
            if defaultFeedHandler != nil && defaultFeedHandler! as String != "com.apple.news",
                let feedHandlerToSet = self.feedHandlers.first(where: {$0.appId == defaultFeedHandler! as String}) {
                
                if self.settingsManager.isSupportedFeedHandler() {
                    self.readerPopUpButton.selectItem(withTitle: feedHandlerToSet.title)
                    self.settingsManager.setFeedHandler(feedHandlerToSet)
                }
            } else {
                if self.feedHandlers.filter({$0.type == FeedHandlerType.app}).count > 0 {
                    self.settingsManager.noFeedHandlerConfiguredAlert()
                } else {
                    self.settingsManager.noFeedHandlersAlert()
                }
            }
        } else {
            if (self.feedHandlers.first(where: {$0.title == feedHandler.title}) != nil) {
                self.readerPopUpButton.selectItem(withTitle: feedHandler.title)
            } else {
                self.settingsManager.noFeedHandlerConfiguredAlert()
            }
        }
    }
    
    func updateSettings() -> Void {
        let feedHandler = self.settingsManager.getFeedHandler()
        
        if feedHandler.type == FeedHandlerType.custom {
            if let url = feedHandler.url {
                self.customUrlTextField.stringValue = url
            }
            
            self.setCustomUrlFieldVisibility(true)
        } else {
            self.setCustomUrlFieldVisibility(false)
        }
        
        if self.settingsManager.getBadgeButtonState() {
            self.badgeButtonToggle.state = NSControl.StateValue.on
        } else {
            self.badgeButtonToggle.state = NSControl.StateValue.off
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let object = obj.object as? NSTextField else { return }
        let value = object.stringValue
        
        if value.contains("%@") {
            self.settingsManager.setFeedHandler(FeedHandlerModel(title: self.customUrlTitle,
                                                                 type: FeedHandlerType.custom,
                                                                 url: value,
                                                                 appId: nil))
        }
    }
    
    func setCustomUrlFieldVisibility(_ visible: Bool, animated: Bool = true) -> Void {
        if visible {
            self.customUrlTextField.isEnabled = true
            self.customUrlTextField.isHidden = false
            NSAnimationContext.runAnimationGroup({ (context) in
                context.allowsImplicitAnimation = true
                context.duration = 0.2
                self.customUrlTextFieldHeightConstraint.animator().constant = CGFloat(21)
                self.customUrlTextFieldPaddingConstraint.animator().constant = CGFloat(16)
            }, completionHandler: { () -> Void in
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.allowsImplicitAnimation = true
                    context.duration = 0.1
                    self.customUrlTextField.animator().alphaValue = 1
                })
            })
        } else {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.allowsImplicitAnimation = true
                context.duration = 0.1
                self.customUrlTextField.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.allowsImplicitAnimation = true
                    context.duration = 0.2
                    self.customUrlTextFieldHeightConstraint.animator().constant = 0
                    self.customUrlTextFieldPaddingConstraint.animator().constant = 0
                }, completionHandler: { () -> Void in
                    self.customUrlTextField.isEnabled = false
                    self.customUrlTextField.isHidden = true
                })
            })
        }
    }
    
    @IBAction func readerPopUpButtonSelected(_ sender: NSMenuItem) -> Void {
        // Set the handler and warn if unsupported
        if let feedHandler = self.feedHandlers.first(where: {$0.title == sender.title}) {
            // Toggle and populate the text field for custom URLs
            if feedHandler.type == FeedHandlerType.custom {
                self.customUrlTextField.stringValue = self.previousCustomUrl ?? feedHandler.url!
                self.setCustomUrlFieldVisibility(true)
                //self.customUrlTextField.window?.makeFirstResponder(self.customUrlTextField)
            } else {
                let previousFeedHandler = self.settingsManager.getFeedHandler()
                
                if previousFeedHandler.type == FeedHandlerType.custom {
                    self.previousCustomUrl = self.customUrlTextField.stringValue
                }
                
                self.setCustomUrlFieldVisibility(false)
            }
            
            self.settingsManager.setFeedHandler(feedHandler)
            
            if !self.settingsManager.isSupportedFeedHandler() {
                self.settingsManager.unsupportedFeedHandlerAlert(withFeedUrl: nil)
            }
        } else {
            self.settingsManager.setFeedHandler(self.settingsManager.defaultFeedHandlers[0])
        }
    }
    
    @IBAction func enableButtonClicked(_ sender: NSButton) -> Void {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionId)
    }
    
    @IBAction func badgeButtonToggleClicked(_ sender: NSButton) -> Void {
        let value = sender.state.rawValue == 0 ? false : true
        
        self.settingsManager.setBadgeButtonState(value)
    }
}

extension NSTextField {
    
    func controlTextDidChange(obj: NSNotification) {}
}
