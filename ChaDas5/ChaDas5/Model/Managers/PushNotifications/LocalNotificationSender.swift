
import UIKit
import UserNotifications

class LocalNotificationSender {
    
    func sendNotification(with title:String, with body:String, count:NSNumber, channelID:String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = count
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0,
                                                        repeats: false)
        
        let requestIdentifier = channelID
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request,
                                               withCompletionHandler: { (error) in
                                                debugPrint("Error sending notification in channel: \(channelID)")
        })
        
        let respondAction = UNTextInputNotificationAction(identifier:
            "respond", title: "Responder", options: [])
        
        let category = UNNotificationCategory(identifier: "actionCategory",
                                              actions: [respondAction],
                                              intentIdentifiers: [],
                                              options: [.hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle])
        content.categoryIdentifier = "actionCategory"
        
        UNUserNotificationCenter.current().setNotificationCategories(
            [category])
    }
}
