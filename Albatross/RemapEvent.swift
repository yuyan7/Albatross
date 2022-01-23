//
//  RemapEvent.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/20.
//

import Cocoa

let keyCodeMap: Dictionary<String, (Int64, Bool)> = [
    "a": (0, false), "A": (0, true),
    "b": (11, false), "B": (11, true),
    "c": (8, false), "C": (8, true),
    "d": (2, false), "D": (2, true),
    "e": (14, false), "E": (14, true),
    "f": (3, false), "F": (3, true),
    "g": (5, false), "G": (5, true),
    "h": (4, false), "H": (4, true),
    "i": (34, false), "I": (34, true),
    "j": (38, false), "J": (38, true),
    "k": (40, false), "K": (40, true),
    "l": (37, false), "L": (37, true),
    "m": (46, false), "M": (46, true),
    "n": (45, false), "N": (45, true),
    "o": (31, false), "O": (31, true),
    "p": (35, false), "P": (35, true),
    "q": (12, false), "Q": (12, true),
    "r": (15, false), "R": (15, true),
    "s": (1, false), "S": (1, true),
    "t": (17, false), "T": (17, true),
    "u": (32, false), "U": (32, true),
    "v": (9, false), "V": (9, true),
    "w": (13, false), "W": (13, true),
    "x": (7, false), "X": (7, true),
    "y": (16, false), "Y": (16, true),
    "z": (6, false), "Z": (6, true),
    "1": (18, false), "!": (18, true),
    "2": (19, false), "@": (19, true),
    "3": (20, false), "#": (20, true),
    "4": (21, false), "$": (21, true),
    "5": (23, false), "%": (23, true),
    "6": (22, false), "^": (22, true),
    "7": (26, false), "&": (26, true),
    "8": (28, false), "*": (28, true),
    "9": (25, false), "(": (25, true),
    "0": (29, false), ")": (29, true),
    "-": (27, false), "_": (27, true),
    "=": (24, false), "+": (24, true),
    "\\": (42, false), "|": (42, true),
    "`": (50, false), "~": (50, true),
    "[": (33, false), "{": (33, true),
    "]": (30, false), "}": (30, true),
    ";": (41, false), ":": (41, true),
    "'": (39, false), "\"": (39, true),
    ",": (43, false), "<": (43, true),
    ".": (47, false), ">": (47, true),
    "/": (44, false), "?": (44, true),
    "Esc": (53, false),
    "Tab": (48, false),
    "Command_L": (102, false),
    "Command_R": (104, false),
    "Delete": (51, false),
    "Return": (36, false),
    "Up": (126, false),
    "Right": (124, false),
    "Down": (125, false),
    "Left": (123, false),
    "Alphabet": (102, false),
    "Kana": (104, false),
    "F1": (122, false),
    "F2": (120, false),
    "F3": (99, false),
    "F4": (118, false),
    "F5": (96, false),
    "F6": (97, false),
    "F7": (98, false),
    "F8": (100, false),
    "F9": (101, false),
    "F10": (109, false),
    "F11": (103, false),
    "F12": (111, false),
    "Ins": (114, false),
    "Del": (117, false),
    "Space": (49, false),
]

let metaKeyMap: Dictionary<String, UInt64> = [
    "Ctrl": 0x040000,
    "Command_L": 0x100010,
    "Command_R": 0x100008,
    "Option_L": 0x080040,
    "Option_R": 0x080120,
    "CapsLock": 0x010000,
]

let UNKNOWN_KEYCODE: Int64 = 999
let DEFAULT_CGEVENT_FLAGS: UInt64 = 256

class KeyEvent: NSObject {
    private var keyCode: Int64 = UNKNOWN_KEYCODE
    private var flag: UInt64 = 0
    
    public func getKeyCode() -> Int64 {
        return keyCode
    }
    
    public func getFlag() -> UInt64 {
        return flag
    }
    
    public func setKeyCode(code: Int64, isShift: Bool) {
        keyCode = code
        if isShift {
            setMetaKey(flag: 0x020000)
        }
    }
    
    public func setMetaKey(flag: UInt64) {
        self.flag |= flag
    }
}

class DestinationEvent: KeyEvent {
    
    
}

class ToggleEvent: DestinationEvent {
    private var state: Bool = false
}

class SourceEvent: KeyEvent {
    private let destination: DestinationEvent
    
    init(destination: DestinationEvent) {
        self.destination = destination
    }
    
    public func match(event: CGEvent) -> Bool {
        if event.getIntegerValueField(.keyboardEventKeycode) != getKeyCode() {
            return false
        }
        
        let flag = getFlag()
        if (event.flags.rawValue & flag) == 0 {
            return false
        }
        
        // CGEventFlags comparison is a little more complecated
        // If combination meta keys are specified Ctrl key only (e.g Ctrl+a) or CapsLock key, we don't care of left or right,
        // and Control/CapsLock meta flag may be different between builtin keyboard and USB keyboard,
        // that's messy but currently we don't know how to distinguish the input source keyboard in CGEvent.
        // So, we gave up to handle it, just compare Control flag of 16-24 bit.
        //
        // On the other hand, Shift, Option, Command keys have left and right keys so we need to compare with lowest 8 bits.
        if (((event.flags.rawValue & 0xFF) & (flag & 0xFF)) == 0) { // Lowest 8 bit comparison for other meta key combination
            if (flag >> 16) == 0x04  { // Control combination only
                return true
            } else if (flag >> 16) == 0x01 { // CapsLock combination only
                return true
            }
            return false
        }
        
        return true
    }
    
    public func convert(event: CGEvent) -> CGEvent {
        event.setIntegerValueField(.keyboardEventKeycode, value: destination.getKeyCode())
        if getFlag() > 0 {
            event.flags = CGEventFlags(rawValue: (destination.getFlag() | DEFAULT_CGEVENT_FLAGS))
        }
        
        return event
    }
   
}

func createRemapEvent(alias: Alias) -> SourceEvent? {
    guard let dst = createDestinationEvent(keys: alias.to) else {
        return nil
    }
    let src = SourceEvent(destination: dst)
    
    for key in alias.from {
        if let m = metaKeyMap[key] {
            src.setMetaKey(flag: m)
        } else if let v = keyCodeMap[key] {
            if src.getKeyCode() != UNKNOWN_KEYCODE {
               return nil
            }
            src.setKeyCode(code: v.0, isShift: v.1)
        } else {
            return nil
        }
    }
    
    return src
}

func createDestinationEvent(keys: [String]) -> DestinationEvent? {
    let dst = DestinationEvent()
    
    for key in keys {
        if let m = metaKeyMap[key] {
            dst.setMetaKey(flag: m)
        } else if let v = keyCodeMap[key] {
            if dst.getKeyCode() != UNKNOWN_KEYCODE {
               return nil
            }
            dst.setKeyCode(code: v.0, isShift: v.1)
        } else {
            return nil
        }
    }
    return dst
}
