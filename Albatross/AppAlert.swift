//
//  AppAlert.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import AppKit

class AppAlert: NSObject {
    private var message: String
    private var information: String?
    
    init(message: String, information: String) {
        self.message = message
        self.information = information
    }
    
    init(message: String) {
        self.message = message
    }
    
    public func display() {
        let alert = NSAlert()
        alert.messageText = message
        if let info = self.information {
            alert.informativeText = info
        }
        alert.runModal()
    }
}
