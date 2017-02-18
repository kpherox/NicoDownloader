/**
 * XmlParser.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Foundation
import Fuzi

class XmlParser {
    
    private(set) var stringEncoding: String.Encoding
    private(set) var xmlData: String
    
    var delegate: XmlParserDelegate?

    init(data: Data, encoding: String.Encoding) {
        self.stringEncoding = encoding
        self.xmlData = String(data: data, encoding: encoding)!
    }
    
    convenience init(data: Data, delegate: XmlParserDelegate?, encoding: String.Encoding) {
        self.init(data: data, encoding: encoding)
        self.delegate = delegate
    }

    func parse() {
        do {
            let xmlDoc = try? XMLDocument(string: self.xmlData, encoding: self.stringEncoding)
            guard let root = xmlDoc?.root else {
                return
            }
            delegate?.parser(element: root)
        } catch let error as XMLError {
            switch error {
            case .noError: print("with this should not appear")
            case .parserFailure, .invalidData: print(error)
            case .libXMLError(let code, let message):
                print("libxml error code: \(code), message: \(message)")
            }
            NSLog("\(error)")
        }
    }

}

protocol XmlParserDelegate {

    func parser(element: Fuzi.XMLElement)

}
