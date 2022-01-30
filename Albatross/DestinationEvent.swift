//
//  DestinationEvent.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/28.
//

import Foundation

protocol DestinationEvent {
    func target() -> KeyEvent
    func isSuppressKeUp() -> Bool
}

class SimpleDestinationEvent: KeyEvent, DestinationEvent {
    private let targetEvent: KeyEvent
    
    init(target: KeyEvent) {
        targetEvent = target
    }
    
    public func isSuppressKeUp() -> Bool {
        return false
    }
    
    public func target() -> KeyEvent {
        return targetEvent
    }
    
    public static func create(_ keys: [String]) -> SimpleDestinationEvent? {
        let evt = KeyEvent()
        
        if keys.count == 1 {
            evt.isSingleKey = true
            if let v = keyCodeMap[keys[0]] {  // swiftlint:disable:this identifier_name
                evt.setKeyCode(code: v.0, isShift: v.1)
            }
            return SimpleDestinationEvent(target: evt)
        }
        
        for key in keys {
            if let m = metaKeyMap[key] {  // swiftlint:disable:this identifier_name
                evt.setMetaKey(flag: m)
            } else if let v = keyCodeMap[key] {  // swiftlint:disable:this identifier_name
                if evt.getKeyCode() != unknownKeyCode {
                   return nil
                }
                evt.setKeyCode(code: v.0, isShift: v.1)
            } else {
                return nil
            }
        }
        return SimpleDestinationEvent(target: evt)
    }
}

class ToggleDestinationEvent: KeyEvent, DestinationEvent {
    private let targetEvents: [DestinationEvent]
    private var index: Int = -1
    
    init(targets: [DestinationEvent]) {
        targetEvents = targets
    }
    
    public func isSuppressKeUp() -> Bool {
        return true
    }
    
    public func target() -> KeyEvent {
        if index == targetEvents.count - 1 {
            index = 0
        } else {
            index += 1
        }
        return targetEvents[index].target()
    }
    
    public static func create(_ toggles: [[String]]) -> ToggleDestinationEvent? {
        var targets: [DestinationEvent] = []
        
        for keys in toggles {
            if let destinationEvent = SimpleDestinationEvent.create(keys) {
                targets.append(destinationEvent)
            } else {
                return nil
            }
        }
        
        return ToggleDestinationEvent(targets: targets)
    }
}

func createDestinationEvent(alias: Alias) -> DestinationEvent? {
    if let toggles = alias.toggles {
        return ToggleDestinationEvent.create(toggles)
    } else if let keys = alias.to {
        return SimpleDestinationEvent.create(keys)
    }
    return nil
}
