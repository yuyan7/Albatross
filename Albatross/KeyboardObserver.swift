//
//  KeyRemap.swift
//  albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/18.
//

import Cocoa

class KeyboardObserver: NSObject {
    override init() {
        super.init()
        print("Constructor")
    }
    
    public func start() {
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        guard let event = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(
                (1 << CGEventType.keyUp.rawValue) |
                (1 << CGEventType.keyDown.rawValue) |
                (1 << CGEventType.flagsChanged.rawValue)
            ),
            callback: { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
            ) -> Unmanaged<CGEvent>? in
                if let observer = refcon {
                    let this = Unmanaged<KeyboardObserver>.fromOpaque(observer).takeUnretainedValue()
                    return this.handleEvent(event: event, type: type)
                }
                return Unmanaged.passUnretained(event)
                
            },
            userInfo: observer
        ) else {
            print("tapCreate failed")
            exit(1)
        }
        
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            CFMachPortCreateRunLoopSource(kCFAllocatorDefault, event, 0),
            .commonModes
        )
        CGEvent.tapEnable(tap: event, enable: true)
        CFRunLoopRun()
    }
    
    private func handleEvent(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        if type == CGEventType.keyDown {
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            let flags = event.flags
            print(keyCode, flags)
            //switch keyCode {
            //case 0: // "a"
            //    event.setIntegerValueField(.keyboardEventKeycode, value: 11)
            //case 11: // "b"
            //    event.setIntegerValueField(.keyboardEventKeycode, value: 0)
            //default:
            //    break
            //}
        }
        return Unmanaged.passUnretained(event)
    }
}

