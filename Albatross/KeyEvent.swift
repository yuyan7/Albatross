//
//  KeyEvent.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/28.
//

import Foundation

class KeyEvent: NSObject {
    private var keyCode: Int64 = unknownKeyCode
    private var flag: UInt64 = 0
    public var isSingleKey: Bool = false
    
    public func getKeyCode() -> Int64 {
        return keyCode
    }
    
    public func getFlag() -> UInt64 {
        return flag
    }
    
    public func setKeyCode(code: Int64, isShift: Bool) {
        keyCode = code
        if isShift {
            setMetaKey(flag: bothShiftKeyFlags)
        }
    }
    
    public func setMetaKey(flag: UInt64) {
        self.flag |= flag
    }
}
