/**
 * GetNicovideo.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Foundation
import Fuzi
import PySwiftyRegex

class Nicolive: XmlParserDelegate {

    private(set) var playerStatus: Dictionary<String, Any>?
    private(set) var streamData: Dictionary<String, Any>?
    private(set) var statusCode: String?
    var live_id: String
    var delegate: NicoliveDelegate?

    required init(live_id: String) {
        self.live_id = live_id
    }
    
    init(live_id: String, delegate: NicoliveDelegate) {
        self.live_id = live_id
        self.delegate = delegate
    }

    func downloadVideo() -> String {
        if self.fetchPlayerStatus() {
            self.rtmpDump()
        }
        return self.statusCode!
    }

    private func fetchPlayerStatus() -> Bool {
        let semaphore =  DispatchSemaphore(value: 0)

        let url = DefConst.playerstatusURL(id: self.live_id)
        let urlSessionConfig = URLSessionConfiguration.default

        let session = URLSession(configuration: urlSessionConfig)
        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, _, _) in

            guard let data = data else {
                self.statusCode = "404 Error"
                semaphore.signal()
                return
            }
            let xmlParser = XmlParser(data: data, delegate: self, encoding: String.Encoding.utf8)
            xmlParser.parse()
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        return self.statusCode == "ok" ? true : false
    }

    private func isPremium() -> Bool {
        let user = self.playerStatus?["user"] as? Dictionary<String, Any>
        guard let isPremium = user?["is_premium"] as? Dictionary<String, Any> else {
            return false
        }

        return isPremium["str"] as! String != "0"
    }

    private func fetchRtmpData() -> (url: String, ticket: String) {
        let rtmp = self.playerStatus?["rtmp"] as? Dictionary<String, Any>
        let url = rtmp?["url"] as? Dictionary<String, Any>
        let ticket = rtmp?["ticket"] as? Dictionary<String, Any>

        return (url!["str"] as! String, ticket!["str"] as! String)
    }

    private func fetchStreamData(_ isOfficial: inout Bool) -> Bool {
        let stream = self.playerStatus?["stream"] as? Dictionary<String, Any>
        guard let quesheet = stream?["quesheet"] as? Dictionary<String, Any> else {
            return false
        }
        self.streamData = quesheet
        let providerType = stream!["provider_type"] as! Dictionary<String, Any>
        isOfficial = providerType["str"] as! String != "community"
        return true
    }

    private func rtmpDump() {
        var isOfficial: Bool = false
        if !self.fetchStreamData(&isOfficial) {
            self.statusCode = "onair"
            return
        }
        if !isOfficial {
            self.statusCode = "user"
            return
        }

        let isPremium = self.isPremium()
        let (url, ticket) = self.fetchRtmpData()

        var rtmpURLs: [String] = []
        var quality: String = "\(self.live_id)"
        for (_, value) in self.streamData! {
            guard let que = value as? Dictionary<String, Any> else {
                self.statusCode = "error"
                return
            }
            let queCmd = que["str"]! as! String
            if queCmd.contains("publish") {
                rtmpURLs.append(queCmd)
            }
            if queCmd.contains("play") {
                quality = self.caseQuality(queCmd, isPremium: isPremium)
            }
        }

        let homeDir: String = NSHomeDirectory()
        let rtmpdumpPath: String = Bundle.main.path(forResource: "rtmpdump", ofType: nil)!

        var count = 0
        for rtmpURL in rtmpURLs {
            let regex = re.compile("\(quality)")
            guard regex.search(rtmpURL) != nil else {
                continue
            }
            count += 1
            let contentURL = "\(url)/mp4:\(self.fetchVideoPath(rtmpURL))"
            let arguments = ["-c", "\(rtmpdumpPath) -r \(contentURL) -C S:\(ticket) -o \(homeDir)/Movies/NicoDownloader/\(self.live_id)_\(count).f4v"]

            let task: Process = Process()
            let pipe: Pipe = Pipe()

            task.launchPath = "/bin/sh"
            task.arguments = arguments

            task.standardOutput = pipe
            task.launch()

            let fileHandle = pipe.fileHandleForReading

            let filename = "\(self.live_id)_\(count).f4v"
            //self.delegate?.updateProgress(0.5)
            self.delegate?.updateStatus(filename: filename)
            
            task.terminationHandler = {
                (_ task: Process) -> Void in
                //self.delegate?.updateProgress(100)
                self.delegate?.finishDownload(filename: filename)
            }

            fileHandle.readInBackgroundAndNotify()
            
            /*
            var rtmpdump = Rtmpdump(url: contentURL.utf8CString, ticket: ticket)
            */
        }

        self.statusCode = "success"
    }

    func parser(element: Fuzi.XMLElement) {
        self.statusCode = element.attr("status") == "ok" ? "ok" : element.firstChild(tag: "error")!.stringValue

        self.playerStatus = self.toDictionary(elements: element.children, rootAttr: element.attributes)
    }

    func toDictionary(elements: [Fuzi.XMLElement], rootAttr: [String : String]? = nil) -> Dictionary<String, Any> {
        var result = Dictionary<String, Any>()
        var valKey = ""
        var dupCount = 1

        if !(rootAttr?.isEmpty)! {
            result.updateValue(rootAttr!, forKey: "attributes")
        }

        for element in elements {
            if result[element.tag!] != nil {
                dupCount += 1
                valKey = "\(element.tag!)_\(dupCount)"
            } else {
                valKey = "\(element.tag!)"
            }

            if element.children.count != 0 {
                result.updateValue(self.toDictionary(elements: element.children, rootAttr: element.attributes), forKey: valKey)
            } else {
                let addVal: [String:Any] = ["str": element.stringValue, "attributes": element.attributes]
                result.updateValue(addVal, forKey: valKey)
            }
        }
        return result
    }

    func fetchVideoPath(_ publish: String) -> String {
        let regex = re.compile("content(.+)f4v")
        guard let match = regex.search(publish) else {
            return ""
        }
        let result = match.group()
        return result!
    }

    func caseQuality(_ play: String, isPremium: Bool) -> String {
        var regex = re.compile("/play (.+) main")
        guard let match = regex.search(play) else {
            return ""
        }

        regex = re.compile("case:(.+)")
        guard let qualities = regex.search(match.group(1)!) else {
            return self.live_id
        }

        regex = re.compile("[,]")
        let qualitiesCase = regex.split(qualities.group(1)!)
        for quality in qualitiesCase {
            if isPremium {
                regex = re.compile("premium:rtmp:(.+)")
            } else {
                regex = re.compile("default:rtmp:(.+)")
            }
            guard let match = regex.search(quality!) else {
                continue
            }
            return match.group(1)!
        }
        return ""
    }

}

protocol NicoliveDelegate {
    
    func updateStatus(filename: String)
    
    func finishDownload(filename: String)
    
}
