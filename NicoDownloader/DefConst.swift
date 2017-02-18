/**
 * DefConst.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Foundation

public class DefConst {
    static let cookieURL = URL(string: "https://account.nicovideo.jp/my/account")!
    static let loginURL = URL(string: "https://account.nicovideo.jp/api/v1/login")!
    static let logoutURL = URL(string: "https://account.nicovideo.jp/logout")!
    static let nicoDLDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!.appendingPathComponent("NicoDownloader").path

    class func userinfoURL(id: String) -> URL {
        return URL(string: "http://www.nicovideo.jp/user/\(id)/video?rss=2.0")!
    }
    
    class func playerstatusURL(id: String) -> URL {
        return URL(string: "http://live.nicovideo.jp/api/getplayerstatus/\(id)")!
    }
}
