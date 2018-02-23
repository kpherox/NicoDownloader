/**
 * PreferencesWindowController.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa

class PreferencesWindowController: NSWindowController {

    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var generalItem: NSToolbarItem!

    static let shared: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name.main, bundle: .main)
        let windowController = storyboard.instantiateController(withIdentifier: .preferencesWindowController)
        return windowController as! PreferencesWindowController
    }()

    private let viewControllers: [NSViewController] = [
        GeneralViewController.shared,
        GeneralViewController.shared,
        ]

    override func windowDidLoad() {
        super.windowDidLoad()
        // Do view setup here.

        guard let item = self.generalItem else {
            self.window?.center()
            return
        }

        self.toolbar.selectedItemIdentifier = item.itemIdentifier

        self.switchView(item)
        self.window?.center()
    }

    func cancel(_ sender: Any?) {
        self.close()
    }

    @IBAction func switchView(_ toolbarItem: NSToolbarItem) {
        let viewController = self.viewControllers[toolbarItem.tag]

        let windowFrame: NSRect = (self.window?.frame)!
        var newWindowFrame: NSRect = (self.window?.frameRect(forContentRect: viewController.view.frame))!
        newWindowFrame.origin.x = windowFrame.origin.x
        newWindowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - newWindowFrame.size.height

        self.window?.contentViewController = nil
        self.window?.title = viewController.title!
        self.window?.setFrame(newWindowFrame, display: true, animate: true)
        self.window?.contentViewController = viewController

    }

}
