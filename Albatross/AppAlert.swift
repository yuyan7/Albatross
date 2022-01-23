//
//  AppAlert.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import AppKit

class AppAlert: NSObject {
    
    public static func display( message: String, information: String) {
        let alert = NSAlert()
        alert.icon = NSImage(named: NSImage.Name("AppMainImage"))
        alert.messageText = message
        alert.informativeText = information
        alert.runModal()
    }
    
    public static func display(message: String) {
        let alert = NSAlert()
        alert.icon = NSImage(named: NSImage.Name("AppMainImage"))
        alert.messageText = message
        alert.runModal()
    }

}
