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
                             selector: #selector(ViewController.checkExtensionState),
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
    
    @objc func checkExtensionState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionId) { [unowned self] (state, error) in
            DispatchQueue.main.async { [weak self] in
                if let status = state?.isEnabled {
                    self?.statusTextField.textColor = status ? .systemGreen : .systemRed
                    self?.statusTextField.stringValue = status ? "● Enabled" : "● Disabled"
                    self?.informationTextField.stringValue = status ? "The extension is enabled. You can add the RSS Button to the Safari toolbar by right clicking and choosing Customize Toolbar." : "The extension is currently disabled. Please enable it from Safari preferences under the extensions tab."
                    self?.enableButton.isHidden = status
                }
            }
        }
    }
    
    func updateFeedHandlers() {
        feedHandlers = settingsManager.defaultFeedHandlers
        
        let foundFeedHandlers = LSCopyAllHandlersForURLScheme("feed" as CFString)?.takeUnretainedValue()
        let identifiers = foundFeedHandlers as! [String]
        for (index, id) in identifiers.enumerated() {
            let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: id)
            let name = FileManager.default.displayName(atPath: path!)
            feedHandlers.insert(FeedHandlerModel(title: name,
                                                 type: FeedHandlerType.app,
                                                 url: nil,
                                                 appId: id), at: 1 + index)
        }
        
        readerPopUpButton.removeAllItems()
        for handler in feedHandlers {
            readerPopUpButton.addItem(withTitle: handler.title)
        }
        readerPopUpButton.selectItem(withTitle: settingsManager.feedHandler.title)
    }
    
    @IBAction func ReaderPopUpSelected(_ sender: NSMenuItem) {
        if let index = feedHandlers.index(where: {$0.title == sender.title}) {
            settingsManager.feedHandler = feedHandlers[index]
            #if DEBUG
            NSLog("Info: feedHandler set (\(settingsManager.feedHandler.title))")
            #endif
        }
    }
    
    @IBAction func enableButtonClicked(_ sender: NSButton) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionId)
    }
    
}
