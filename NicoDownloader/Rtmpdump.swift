/**
 * Rtmpdump.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Cocoa
import CRtmp

class Rtmpdump {
    var rtmp: RTMP
    
    var rtmpProtocol: Int32 = RTMP_PROTOCOL_UNDEFINED
    var hostname: AVal = AVal(av_val: nil, av_len: 0)
    var port: Int32 = -1
    var playpath: AVal = AVal(av_val: nil, av_len: 0)
    var app: AVal = AVal(av_val: nil, av_len: 0)

    var swfSize: UInt32 = 0
    var dStart: Int32 = 0
    var dStop: Int32 = 0
    var bLiveStream: Int32 = 0
    var timeout: Int = 0
    var socksHost: AVal = AVal(av_val: nil, av_len: 0)
    var tcUrl: AVal = AVal(av_val: nil, av_len: 0)
    var swfUrl: AVal = AVal(av_val: nil, av_len: 0)
    var pageUrl: AVal = AVal(av_val: nil, av_len: 0)
    var auth: AVal = AVal(av_val: nil, av_len: 0)
    var swfSHA256Hash: AVal = AVal(av_val: nil, av_len: 0)
    var flashVer: AVal = AVal(av_val: nil, av_len: 0)
    var subscribePath: AVal = AVal(av_val: nil, av_len: 0)
    var usherToken: AVal = AVal(av_val: nil, av_len: 0)
    var nlPlayPath: AVal = AVal(av_val: nil, av_len: 0)
    var nlToken: AVal = AVal(av_val: nil, av_len: 0)
    var nlId: AVal = AVal(av_val: nil, av_len: 0)
    
    var av_conn: AVal = "conn".avc

    init(url: UnsafeMutablePointer<Int8>!, ticket: String) {
        var parsedProtocol: Int32 = -1
        var parsedHost: AVal = AVal(av_val: nil, av_len: 0)
        var parsedPlaypath: AVal = AVal(av_val: nil, av_len: 0)
        var parsedApp: AVal = AVal(av_val: nil, av_len: 0)
        var parsedPort: UInt32 = 0
        
        var av = ticket.toAVal
        RTMP_ParseURL(url, &parsedProtocol, &parsedHost, &parsedPort, &parsedPlaypath, &parsedApp)
        
        rtmp = RTMP_Alloc().pointee
        RTMP_Init(&self.rtmp)
        
        RTMP_SetOpt(&self.rtmp, &self.av_conn, &av)
        
        hostname = parsedHost
        port = Int32(parsedPort)
        if (parsedPlaypath.av_len == 1) {
            playpath = parsedPlaypath
        }
        rtmpProtocol = parsedProtocol;
        if (parsedApp.av_len == 1) {
            app = parsedApp;
        }
        
        RTMP_SetupStream(&self.rtmp, rtmpProtocol, &hostname, UInt32(port), &socksHost, &playpath, &tcUrl, &swfUrl, &pageUrl, &app, &auth, &swfSHA256Hash, swfSize, &flashVer, &subscribePath, &usherToken, dStart, dStop, bLiveStream, timeout, &nlPlayPath, &nlToken, &nlId)
    }
}
