//
//  AppNotification.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import UserNotifications

let MESSAGE_IDENTIFIER = "albatross-notification"

class AppNotification: NSObject {
    private var body: String
    private var subtitle: String?
    
    init(body: String) {
        self.body = body
    }
    init(body: String, subtitle: String) {
        self.body = body
        self.subtitle = subtitle
    }
    
    public func display() {
        let content = UNMutableNotificationContent()
        content.title = "Albatross"
        if let st = subtitle {
            content.subtitle = st
        }
        content.body = body
        content.sound = .none
        
        let request = UNNotificationRequest(identifier: MESSAGE_IDENTIFIER, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [MESSAGE_IDENTIFIER])
        center.requestAuthorization(options: [.alert]) { _, _ in }
        center.add(request)
    }
}
