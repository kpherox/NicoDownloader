/**
 * NicoAccount.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Foundation
import Fuzi

class NicoAccount: XmlParserDelegate {
    
    private(set) var loggingFlag: Bool?
    private(set) var username: String?
    private(set) var userID: String?
    
    required init() {
        self.loggingFlag = self.loggingCheck()
    }
    
    func loggingCheck() -> Bool {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let cookies = HTTPCookieStorage.shared.cookies(for: DefConst.cookieURL)
        if (cookies?.isEmpty)! {
            self.loggingFlag = false
            self.username = "Not logged in"
            self.userID = "Not logged in"
            return self.loggingFlag!
        }
        
        let semaphore =  DispatchSemaphore(value: 0)
        let cookie = HTTPCookie.requestHeaderFields(with: cookies!)
        
        var request = URLRequest(url: DefConst.cookieURL)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = cookie
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (_, response, _) -> Void in
            
            guard let httpResponse: HTTPURLResponse = response as! HTTPURLResponse? else {
                session.invalidateAndCancel()
                self.loggingFlag = false
                self.username = "404 Error"
                self.userID = "404 Error"
                semaphore.signal()
                return
            }
            
            if httpResponse.allHeaderFields["x-niconico-authflag"] as! String == "0" {
                semaphore.signal()
                self.loggingFlag = false
                self.username = "Not logged in"
                self.userID = "Not logged in"
                return
            }
            self.loggingFlag = true
            self.userID = httpResponse.allHeaderFields["x-niconico-id"] as? String
            self.getUsername()
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        return self.loggingFlag!
    }

    func getUsername() {
        if !self.loggingFlag! {
            return
        }
        
        let semaphore =  DispatchSemaphore(value: 0)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: DefConst.userinfoURL(id: self.userID!))
        request.httpMethod = "POST"
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (data, response, _) -> Void in
            
            guard let _: HTTPURLResponse = response as! HTTPURLResponse? else {
                session.invalidateAndCancel()
                self.loggingFlag = false
                self.username = "404 Error"
                self.userID = "404 Error"
                semaphore.signal()
                return
            }
            
            let xmlParser = XmlParser(data: data!, delegate: self, encoding: String.Encoding.utf8)
            xmlParser.parse()
            
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    func parser(element: Fuzi.XMLElement) {
        let userInfo = self.toDictionary(elements: element.children, rootAttr: element.attributes)
        guard let userChannel: Dictionary<String, Any> = userInfo["channel"] as? Dictionary<String, Any> else {
            return
        }
        guard let userName = userChannel["creator"] as? Dictionary<String, Any> else {
            return
        }
        
        self.username = (userName["str"] as! String)
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
                let addVal: [String:Any] = ["str":element.stringValue, "attributes":element.attributes]
                result.updateValue(addVal, forKey: valKey)
            }
        }
        return result
    }

    func loggingIn(mail_tel: String, password: String) -> Bool {
        if self.loggingFlag! {
            self.loggingOut()
        }
        
        let semaphore =  DispatchSemaphore(value: 0)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: DefConst.loginURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // set the request-body(JSON)
        let params: [String: Any] = [
            "mail_tel": mail_tel,
            "password": password
        ]

        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])

        let task: URLSessionDataTask = session.dataTask(with: request) {
            (_, response, _) -> Void in

            guard let httpResponse: HTTPURLResponse = response as! HTTPURLResponse? else {
                session.invalidateAndCancel()
                self.loggingFlag = false
                self.username = "404 Error"
                self.userID = "404 Error"
                semaphore.signal()
                return
            }
            
            // Since the incoming cookies will be stored in one of the header fields in the HTTP Response, parse through the header fields to find the cookie field and save the data
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String : String], for: httpResponse.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: DefConst.cookieURL, mainDocumentURL: nil)

            if httpResponse.allHeaderFields["x-niconico-authflag"] as! String == "0" {
                self.loggingFlag = false
                self.username = "Not logged in"
                self.userID = "Not logged in"
                semaphore.signal()
                return
            }
            self.loggingFlag = true
            self.userID = (httpResponse.allHeaderFields["x-niconico-id"] as! String)
            self.getUsername()
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return self.loggingFlag!
    }
    
    func loggingOut() {
        if !self.loggingFlag! {
            return
        }
        
        let semaphore =  DispatchSemaphore(value: 0)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: DefConst.logoutURL)
        request.httpMethod = "GET"
        
        let task: URLSessionDataTask = session.dataTask(with: request) {
            (_, response, _) -> Void in
            
            guard let httpResponse: HTTPURLResponse = response as! HTTPURLResponse? else {
                session.invalidateAndCancel()
                self.loggingFlag = false
                self.username = "404 Error"
                self.userID = "404 Error"
                semaphore.signal()
                return
            }
            
            // Since the incoming cookies will be stored in one of the header fields in the HTTP Response, parse through the header fields to find the cookie field and save the data
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String : String], for: httpResponse.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: DefConst.cookieURL, mainDocumentURL: nil)
            self.loggingFlag = false
            self.username = "Not logged in"
            self.userID = "Not logged in"
            
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }

}
