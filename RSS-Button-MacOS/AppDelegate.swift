//
//  AppDelegate.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-20.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBAction func closeMenuItemClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        //let feedHandlersAvailable = [FeedHandlerModel]()
        //ViewController.updateFeedHandlers(with: feedHandlersAvailable)
        //LSCopyDefaultHandlerForURLScheme("feed" as CFString)?.takeUnretainedValue() as String?
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

