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
    
    @IBAction func showHelpMenuItemClicked(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: Bundle.main.infoDictionary!["Help URL"] as! String)!)
    }
    
    @IBAction func showPrivacyMenuItemClicked(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: Bundle.main.infoDictionary!["Privacy URL"] as! String)!)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {}
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

