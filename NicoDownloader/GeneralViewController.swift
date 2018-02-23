/**
 * GeneralViewController.swift
 *
 * Copyright (c) 2018 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa

class GeneralViewController: NSViewController {

    @IBOutlet weak var usernameLabel: NSTextField!
    @IBOutlet weak var userIDLabel: NSTextField!
    @IBOutlet weak var mailLabel: NSTextField!
    @IBOutlet weak var mailField: NSTextField!
    @IBOutlet weak var passLabel: NSTextField!
    @IBOutlet weak var passField: NSSecureTextField!
    @IBOutlet weak var loggingButton: NSButton!

    let nicoAccount = NicoAccount()

    static let shared: GeneralViewController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name.main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .generalViewController)
        return windowController as! GeneralViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.updateLabel()
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
