//
//  PushNotifications.swift
//  MeAcompanha
//
//  Created by Julia Maria Santos on 19/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class DaoPushNotifications: Codable {
    
    static var instance: DaoPushNotifications!
    var subscriptionId: CKSubscription.ID

    
    init(subscriptionId: CKSubscription.ID = "") {
        self.subscriptionId = subscriptionId
        DaoPushNotifications.instance = self
    }

    private func createSubscription(recordType: String, predicate: NSPredicate, option: CKQuerySubscription.Options) {
        let subscription = CKQuerySubscription(recordType: recordType, predicate: predicate, options: option)
        let info = CKSubscription.NotificationInfo()
        info.shouldBadge = true
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        DAOManager.instance?.database.save(subscription, completionHandler: { subs, error in
            if error == nil {
                print("Subscription saved successfully")
                self.subscriptionId = subscription.subscriptionID
                do { try DaoPushNotifications.instance.save()
                } catch {
                    print("error")
                    let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    alert.present(CreateNewAccount(), animated: true, completion: nil)
                    alert.present(Login(), animated: true, completion: nil)
                }
            } else {
                print("An error occurred")
                print(error as Any)
            }
        })
    }
    
    func deleteSubscription() {
        DAOManager.instance?.database.delete(withSubscriptionID: self.subscriptionId, completionHandler: {(description, error) in
            if error == nil {
                print("Subscription deleted successfully")
                self.subscriptionId = ""
                do { try DaoPushNotifications.instance.save()
                } catch {
                    print("error")
                    let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    alert.present(CreateNewAccount(), animated: true, completion: nil)
                    alert.present(Login(), animated: true, completion: nil)
                }
            } else {
                print("An error occurred")
            }
        })
    }
    
    private func notification() -> CKSubscription.NotificationInfo {
        let info = CKSubscription.NotificationInfo()
        info.alertBody = "Você recebeu uma nova mensagem."
        info.shouldBadge = true
        info.soundName = "default"
        return info
    }
}
