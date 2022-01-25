//
//  RemapEvent.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/20.
//

import Cocoa

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

class SourceEvent: KeyEvent {
    private let destination: KeyEvent
    
    init(destination: KeyEvent) {
        self.destination = destination
    }
    
    public func match(event: CGEvent) -> Bool {
        if event.getIntegerValueField(.keyboardEventKeycode) != getKeyCode() {
            print("keycode mismatch")
            return false
        }
        
        // When single key shortcut, no need to compare flags
        if isSingleKey {
            return true
        }
        
        let flag = getFlag()
        if (event.flags.rawValue & flag) == 0 {
            print("flag mismatch", event.flags, flag)
            return false
        }
        
        // CGEventFlags comparison is a little complecated.
        // If combination meta keys are specified Ctrl key only (e.g Ctrl+a) or CapsLock key,
        // we don't care of left or right and Control/CapsLock meta flag may be different
        // between builtin keyboard and USB keyboard.
        // That's messy but currently we don't know how to distinguish the input source keyboard in CGEvent.
        // So, we gave up to handle it, just compare Control flag of 16-24 bit.
        //
        // On the other hand, Shift, Option, Command keys have left and right keys
        // so we need to compare with lowest 8 bits to distinguish them.
        if ((event.flags.rawValue & 0xFF) & (flag & 0xFF)) == 0 {
            if (flag >> 16) == 0x04 { // Control combination only
                return true
            } else if (flag >> 16) == 0x01 { // CapsLock combination only
                return true
            }
            print("left/right mismatch")

            return false
        }
        
        return true
    }
    
    public func convert(event: CGEvent) -> CGEvent {
        event.setIntegerValueField(.keyboardEventKeycode, value: destination.getKeyCode())
        if destination.getFlag() != defaultCGEventFlags {
            event.flags = CGEventFlags(rawValue: (destination.getFlag() | defaultCGEventFlags))
        }
        print("converted", event.getIntegerValueField(.keyboardEventKeycode), event.flags)
        
        return event
    }
   
}

func createRemapEvent(alias: Alias) -> SourceEvent? {
    guard let dst = createDestinationEvent(keys: alias.to) else {
        return nil
    }
    let src = SourceEvent(destination: dst)
    let keys = alias.from
    
    if keys.count == 1 {
        src.isSingleKey = true
        if let v = keyCodeMap[keys[0]] {  // swiftlint:disable:this identifier_name
            src.setKeyCode(code: v.0, isShift: v.1)
        }
        return src
    }
    
    for key in keys {
        if let m = metaKeyMap[key] {  // swiftlint:disable:this identifier_name
            src.setMetaKey(flag: m)
        } else if let v = keyCodeMap[key] {  // swiftlint:disable:this identifier_name
            if src.getKeyCode() != unknownKeyCode {
               return nil
            }
            src.setKeyCode(code: v.0, isShift: v.1)
        } else {
            return nil
        }
    }
    
    return src
}

func createDestinationEvent(keys: [String]) -> KeyEvent? {
    let dst = KeyEvent()
    
    if keys.count == 1 {
        dst.isSingleKey = true
        if let v = keyCodeMap[keys[0]] {  // swiftlint:disable:this identifier_name
            dst.setKeyCode(code: v.0, isShift: v.1)
        }
        return dst
    }
    
    for key in keys {
        if let m = metaKeyMap[key] {  // swiftlint:disable:this identifier_name
            dst.setMetaKey(flag: m)
        } else if let v = keyCodeMap[key] {  // swiftlint:disable:this identifier_name
            if dst.getKeyCode() != unknownKeyCode {
               return nil
            }
            dst.setKeyCode(code: v.0, isShift: v.1)
        } else {
            return nil
        }
    }
    return dst
}
