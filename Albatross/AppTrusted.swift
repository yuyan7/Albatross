//
//  AppTrusted.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/24.
//

import Cocoa

class AppTrusted: NSObject {
    
    static func isTrusted(callback: @escaping () -> Void) {
        
        let prompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options: CFDictionary = [prompt: true] as NSDictionary
        
        if !AXIsProcessTrustedWithOptions(options) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer: Timer) in
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    callback()
                }
            }
        } else {
            callback()
        }
    }
}
