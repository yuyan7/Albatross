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
                // If event refernece comes from our observer handle it
                if let observer = refcon {
                    let this = Unmanaged<KeyboardObserver>.fromOpaque(observer).takeUnretainedValue()
                    
                    // If remapping is paused, do nothing
                    if this.isPaused {
                        return Unmanaged.passUnretained(event)
                    }
                    
                    switch type {
                    case CGEventType.keyDown:
                        print("keydown", event.getIntegerValueField(.keyboardEventKeycode), event.flags)
                        if let converted = this.handleEvent(event: event) {
                            return Unmanaged.passUnretained(converted)
                        }
                        break
                    case CGEventType.keyUp:
                        print("keyup", event.getIntegerValueField(.keyboardEventKeycode), event.flags)
                        if let converted = this.handleEvent(event: event) {
                            return Unmanaged.passUnretained(converted)
                        }
                        break
                    case CGEventType.flagsChanged:
                        print("meta", event.getIntegerValueField(.keyboardEventKeycode), event.flags)
                        // If meta key is pressed, we should handle in this case but we need to consider combination key remapping.
                        // On combination key remapping, it should be handled in keyDown and keyUp case
                        // so this case treats single metaKey is pressed and handle only keyUp case
                        if event.flags.rawValue != DEFAULT_CGEVENT_FLAGS {
                            if let converted = this.handleEvent(event: event) {
                                print("Post emurated event")
                                // If metakey event is converted, need to emurate keyDown/keyUp event to tap
                                let keyCode = converted.getIntegerValueField(.keyboardEventKeycode)
                                print("Post emurated event", keyCode, converted.flags)
                                let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: true)!
                                keyDown.flags = CGEventFlags(rawValue: getFlagsForKeyCode(keyCode: keyCode))
                                let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(keyCode), keyDown: false)!
                                keyUp.flags = CGEventFlags(rawValue: DEFAULT_CGEVENT_FLAGS)
                                print(keyUp.flags)
                                keyDown.post(tap: CGEventTapLocation.cghidEventTap)
                                keyUp.post(tap: CGEventTapLocation.cghidEventTap)

                                return Unmanaged.passUnretained(event)
                            }
                            break
                        }
                        break
                    default:
                        break
                    }
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
    
    private func handleEvent(event: CGEvent) -> CGEvent? {
        let aliases = alias.getAliases()
        print(aliases, event.getIntegerValueField(.keyboardEventKeycode))
        
        if let sources = aliases[event.getIntegerValueField(.keyboardEventKeycode)] {
            print("sources", sources)
            for s in sources {
                if s.match(event: event) {
                    print("matched")
                    return s.convert(event: event)
                }
            }
        }
        return nil
    }
}

