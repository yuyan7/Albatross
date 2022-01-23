//
//  AppNotification.swift
//  Albatross
//
//  Created by Yoshiaki Sugimoto on 2022/01/23.
//

import Foundation
import UserNotifications

class AppNotification: NSObject {
    
    public static func display(body: String) {
        let content = UNMutableNotificationContent()
        content.title = "Albatross"
        content.body = body
        content.sound = .none
        
        show(content: content)
    }
    
    public static func display(body: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Albatross"
        content.subtitle = subtitle
        content.body = body
        content.sound = .none
        
        show(content: content)
    }
    
    class func show(content: UNMutableNotificationContent) {
        let ident = UUID().uuidString
        let request = UNNotificationRequest(identifier: ident, content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert]) { _, _ in }
        center.add(request)
    }
}
