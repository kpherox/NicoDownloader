/**
 * PreferencesWindow.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa

class PreferencesController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Do view setup here.
    }

}

class PreferencesViewController: NSViewController {

    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var userIDLabel: NSTextField!
    @IBOutlet weak var mailLabel: NSTextField!
    @IBOutlet weak var mailField: NSTextField!
    @IBOutlet weak var passLabel: NSTextField!
    @IBOutlet weak var passField: NSSecureTextField!
    @IBOutlet weak var loggingButton: NSButton!
    
    let nicoAccount = NicoAccount()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLabel()
        // Do view setup here.
    }
    
    func updateLabel() {
        self.loggingButton.title = self.nicoAccount.loggingFlag! ? "Logout" : "Login"
        self.usernameLabel.stringValue = self.nicoAccount.username!
        self.userIDLabel.stringValue = self.nicoAccount.userID!
        if mailLabel.textColor == NSColor.red {
            mailLabel.textColor = NSColor.textColor
            passLabel.textColor = NSColor.textColor
        }
    }

    @IBAction func pushLogging(_ sender: NSButton) {
        if self.nicoAccount.loggingFlag! {
            self.nicoAccount.loggingOut()
            self.updateLabel()
        } else {
            if self.nicoAccount.loggingIn(mail_tel: self.mailField.stringValue, password: self.passField.stringValue) {
                self.updateLabel()
            } else {
                mailLabel.textColor = NSColor.red
                passLabel.textColor = NSColor.red
            }
        }
    }
}
