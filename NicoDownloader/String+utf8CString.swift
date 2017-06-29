/**
 * String+utf8CString.swift
 *
 * Copyright (c) 2017 kPherox.
 *
 * This software is released under the MIT License.
 * https://github.com/kPherox/NicoDownloader/blob/master/LICENSE
 */

import Foundation
import CRtmp

extension String {
    var utf8CString: UnsafeMutablePointer<Int8>? {
        return UnsafeMutablePointer(mutating: (self as NSString).utf8String!)
    }
    var avc: AVal {
        return AVal(av_val: self.utf8CString, av_len: Int32( MemoryLayout.size(ofValue: self) - 1 ))
    }
    var toAVal: AVal {
        return AVal(av_val: self.utf8CString, av_len: Int32(self.characters.count))
    }
}
