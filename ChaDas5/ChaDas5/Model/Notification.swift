//
//  Notification.swift
//  MeAcompanha
//
//  Created by Giuliana Moté on 18/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import UserNotifications

class Notification: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func sendNotification(title: String, subtitle: String, body: String){
        UNUserNotificationCenter.current().getNotificationSettings{(settings) in
            guard settings.authorizationStatus == .authorized else { return }
            
            let content = UNMutableNotificationContent()
            
            content.categoryIdentifier = "notification"
            
            content.title = title
            content.subtitle = subtitle
            content.body = body
            content.sound = UNNotificationSound.default
            
            self.triggerNotification(with: content)
        }
    }
    
    func triggerNotification(with content: UNNotificationContent){
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
