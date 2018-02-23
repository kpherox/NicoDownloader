/**
 * AppDelegate.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // Click dock icon to reopen.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for openWindow: NSWindow in sender.windows {
                openWindow.makeKeyAndOrderFront(self)
            }
        }
        return true
    }

}
