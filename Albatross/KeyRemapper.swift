//
//  KeyRemapper.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import AppKit

let keyboardBit: UInt64 = 0x700000000

class KeyRemapper: NSObject {
    private var defaults: [[String: UInt64]] = []
    
    private let system: IOHIDEventSystemClient
    private let services: CFArray?
    private var isPaused: Bool = false
        
    override init() {
        self.system = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)
        self.services = IOHIDEventSystemClientCopyServices(system)

        for i: UInt64 in 0x04 ..< 0xF0 {
            let o: UInt64 = i | keyboardBit
            defaults.append([
                kIOHIDKeyboardModifierMappingSrcKey: o, kIOHIDKeyboardModifierMappingDstKey: o
            ])
        }
    }
    
    public func pause() {
        isPaused = true
    }
    
    public func resume(config: AppConfig) {
        isPaused = false
        remap(config: config)
    }
    
    public func updateConfig(config: AppConfig) {
        if isPaused {
            return
        }
        remap(config: config)
    }
    
    private func remap(config: AppConfig) {
        // Firstly, clear all mappings before update remap
        self.restore()
        
        var remaps: [[String: UInt64]] = []
        for (key, value) in config.getRemap() {
            if let src = remapKeyTable[key], let dst = remapKeyTable[value] {
                remaps.append([
                    kIOHIDKeyboardModifierMappingSrcKey: src | keyboardBit,
                    kIOHIDKeyboardModifierMappingDstKey: dst | keyboardBit,
                ])
                continue
            }
        }
        print("remap \(remaps)")
        
        if remaps.count == 0 {
            return
        }
        
        for service in services as! [IOHIDServiceClient] {
            if((IOHIDServiceClientConformsTo(service, UInt32((kHIDPage_GenericDesktop)), UInt32(kHIDUsage_GD_Keyboard))) != 0) {
                IOHIDServiceClientSetProperty(service, kIOHIDUserKeyUsageMapKey as CFString, remaps as CFArray)
            }
        }
        
        
    }
    
    public func restore() {
        print("Restore key remap")
        for service in services as! [IOHIDServiceClient] {
            if((IOHIDServiceClientConformsTo(service, UInt32((kHIDPage_GenericDesktop)), UInt32(kHIDUsage_GD_Keyboard))) != 0) {
                IOHIDServiceClientSetProperty(service, kIOHIDUserKeyUsageMapKey as CFString, defaults as CFArray)
            }
        }
    }
}

// https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
let remapKeyTable: Dictionary<String, UInt64> = [
    "a": 0x04, "A": 0x04,
    "b": 0x05, "B": 0x05,
    "c": 0x06, "C": 0x06,
    "d": 0x07, "D": 0x07,
    "e": 0x08, "E": 0x08,
    "f": 0x09, "F": 0x09,
    "g": 0x0A, "G": 0x0A,
    "h": 0x0B, "H": 0x0B,
    "i": 0x0C, "I": 0x0C,
    "j": 0x0D, "J": 0x0D,
    "k": 0x0E, "K": 0x0E,
    "l": 0x0F, "L": 0x0F,
    "m": 0x10, "M": 0x10,
    "n": 0x11, "N": 0x11,
    "o": 0x12, "O": 0x12,
    "p": 0x13, "P": 0x13,
    "q": 0x14, "Q": 0x14,
    "r": 0x15, "R": 0x15,
    "s": 0x16, "S": 0x16,
    "t": 0x17, "T": 0x17,
    "u": 0x18, "U": 0x18,
    "v": 0x19, "V": 0x19,
    "w": 0x1A, "W": 0x1A,
    "x": 0x1B, "X": 0x1B,
    "y": 0x1C, "Y": 0x1C,
    "z": 0x1D, "Z": 0x1D,
    "1": 0x1E, "!": 0x1E,
    "2": 0x1F, "@": 0x1F,
    "3": 0x20, "#": 0x20,
    "4": 0x21, "$": 0x21,
    "5": 0x22, "%": 0x22,
    "6": 0x23, "^": 0x23,
    "7": 0x24, "&": 0x24,
    "8": 0x25, "*": 0x25,
    "9": 0x26, "(": 0x26,
    "0": 0x27, ")": 0x27,
    "-": 0x2D, "_": 0x2D,
    "=": 0x2E, "+": 0x2E,
    "\\": 0x31, "|": 0x31,
    "`": 0x35, "~": 0x35,
    "[": 0x2F, "{": 0x2F,
    "]": 0x30, "}": 0x30,
    ";": 0x33, ":": 0x33,
    "'": 0x34, "\"": 0x34,
    ",": 0x36, "<": 0x36,
    ".": 0x37, ">": 0x37,
    "/": 0x38, "?": 0x38,
    "Esc": 0x29,
    "Tab": 0x2B,
    "Ctrl": 0xE0,
    "Shift_L": 0xE1,
    "Shift_R": 0xE5,
    "Command_L": 0xE3,
    "Command_R": 0xE7,
    "Option_L": 0xE2,
    "Option_R": 0xE6,
    "Delete": 0x2A,
    "Return": 0x28,
    "Up": 0x52,
    "Right": 0x4F,
    "Down": 0x51,
    "Left": 0x50,
    "F1":  0x3A,
    "F2":  0x3B,
    "F3":  0x3C,
    "F4":  0x3D,
    "F5":  0x3E,
    "F6":  0x3F,
    "F7":  0x40,
    "F8":  0x41,
    "F9":  0x42,
    "F10": 0x43,
    "F11": 0x44,
    "F12": 0x45,
    "Ins": 0x49,
    "Del": 0x4C,
    "Space": 0x2C,
    "CapsLock": 0x39,
]
