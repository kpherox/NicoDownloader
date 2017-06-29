/**
 * ViewController.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa
import PySwiftyRegex

class ViewController: NSViewController, NicoliveDelegate {

    @IBOutlet weak var checkLoggingIndicator: NSProgressIndicator!
    @IBOutlet weak var checkLogging: NSTextField!
    @IBOutlet weak var downloadStatus: NSProgressIndicator!
    @IBOutlet weak var statusCode: NSTextField!
    @IBOutlet weak var downloadFilename: NSTextField!
    @IBOutlet weak var liveID: NSTextField!

    override func loadView() {
        super.loadView()
        
        do {
            try FileManager.default.createDirectory(atPath: DefConst.nicoDLDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkLogging.textColor = NSColor.textColor
        self.checkLogging.stringValue = ""
        self.statusCode.stringValue = ""
        // Do any additional setup after loading the view.
    }

    @IBAction func download(_ sender: NSButton) {
        let nicoAccount = NicoAccount()
        let loggingCheck = nicoAccount.loggingCheck()

        if loggingCheck {
            self.checkLogging.textColor = NSColor.green
            self.checkLogging.stringValue = "Logged in"
        } else {
            self.checkLogging.textColor = NSColor.red
            self.checkLogging.stringValue = "Not logged in"
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "No Login"
            return
        }

        let nicolive = Nicolive(live_id: self.liveID.stringValue, delegate: self)
        let status = nicolive.downloadVideo()

        switch status {
        case "success", "ok":
            break
        case "user":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Not support user live"
        case "onair":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Not support while broadcast"
        case "notfound":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Not found"
        case "comingsoon":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Not been broadcast yet"
        case "closed":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Has been closed"
        case "require_accept_print_timeshift_ticket":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Not been timeshifted"
        case "timeshift_ticket_exhaust":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Timeshift ticket usage count has been exhausted"
        case "timeshift_ticket_expire":
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = "Timeshift ticket has been expired"
        default:
            self.statusCode.textColor = NSColor.red
            self.statusCode.stringValue = status
            NSLog(status)
        }
    }

    func updateStatus(filename: String) {
        self.downloadFilename.stringValue = "Downloading \(filename)"
        self.downloadStatus.startAnimation(nil)
    }

    func finishDownload(filename: String) {
        self.downloadStatus.stopAnimation(nil)
        self.downloadFilename.stringValue = "Download to \(DefConst.nicoDLDir)/\(filename)"
        self.statusCode.textColor = NSColor.textColor
        self.statusCode.stringValue = "Finish!"
    }

}
