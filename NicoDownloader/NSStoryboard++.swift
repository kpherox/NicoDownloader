//
//  NSStoryboard++.swift
//  NicoDownloader
//
//  Created by kPherox on 2018/02/23.
//  Copyright © 2018 kPherox. All rights reserved.
//

import Foundation
import AppKit

extension NSStoryboard.Name {

    static let main: NSStoryboard.Name = NSStoryboard.Name(Bundle.main.infoDictionary!["NSMainStoryboardFile"] as! String)

}

extension NSStoryboard.SceneIdentifier {

    static let preferencesWindowController = NSStoryboard.SceneIdentifier("PreferencesWindowController")
    static let generalViewController = NSStoryboard.SceneIdentifier("GeneralViewController")

}
