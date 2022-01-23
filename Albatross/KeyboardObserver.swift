//
//  KeyboardObserver.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/18.
//

import Cocoa

enum KeyboardOberserError: Error {
    case startFail
}

class KeyboardObserver: NSObject {
    private var alias: KeyAlias
    private var isPaused: Bool = false
    
    init(alias: KeyAlias) {
        self.alias = alias
    }
    
    public func pause() {
        isPaused = true
    }
    
    public func resume() {
        isPaused = false
    }
    
    public func start() throws {
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
            throw KeyboardOberserError.startFail
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
        // If remapping is paused, do nothing
        if isPaused {
            return Unmanaged.passUnretained(event)
        }
        
        if type == CGEventType.keyDown || type == CGEventType.keyUp{
            let aliases = alias.getAliases()
            if let sources = aliases[event.getIntegerValueField(.keyboardEventKeycode)] {
                for s in sources {
                    if s.match(event: event) {
                        return Unmanaged.passUnretained(s.convert(event: event))
                    }
                }
                
            }
        }
        return Unmanaged.passUnretained(event)
    }
}

