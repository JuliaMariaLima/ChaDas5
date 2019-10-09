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

    
    init() {
        DaoPushNotifications.instance = self
    }

    func createSubscription(recordType: String, predicate: NSPredicate, option: CKQuerySubscription.Options, on channel: String) {
        let subscription = CKQuerySubscription(recordType: recordType, predicate: predicate, options: option)
        let info = self.notificationInfo()
        subscription.notificationInfo = info
        DAOManager.instance?.database.save(subscription, completionHandler: { subs, error in
            if error == nil {
                print("Subscription saved successfully")
                self.saveSubscription(from: channel, with: subscription.subscriptionID)
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
    
    func saveSubscription(from channel: String, with subscriptionID: String) {
        let record = CKRecord(recordType: "Subscriptions")
        record.setValue(channel, forKey: "channel")
        record.setValue(subscriptionID, forKey: "subscriptionID")
        record.setValue(MeUser.instance.email, forKey: "user")
        
        DAOManager.instance?.database.save(record, completionHandler: { (record, error) in
            if error != nil {
                debugPrint("error saving subscription", error!.localizedDescription)
                return
            }
            if record != nil {
                debugPrint("subscription saved")
            }
        })
        
    }
    
    func deleteSubscription(subscription: String) {
        DAOManager.instance?.database.delete(withSubscriptionID: subscription, completionHandler: {(description, error) in
            if error == nil {
                print("Subscription deleted successfully")
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
    
    func deleteSubscriptionRecord(from channel: String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Subscriptions", predicate: predicate)
        DAOManager.instance?.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
               debugPrint("error fetching subscription", error!.localizedDescription)
                return
            }
            if results != nil {
                for result in results! {
                    guard let resultChannel = result["channel"] as? String else { return }
                    guard let subscriptionID = result["subscriptionID"] as? String else { return }
                    if resultChannel == channel {
                        DAOManager.instance?.database.delete(withRecordID: result.recordID, completionHandler: { (record, error) in
                            if error != nil {
                                debugPrint("deleted!")
                            }
                        })
                        self.deleteSubscription(subscription: subscriptionID)
                    }
                }
            }
        })
    }
    
    func retrieveSubscription(on channel:String, completion: @escaping (Bool?) -> Void) {
        let predicate = NSPredicate(format: "channel = %@", channel)
         let query = CKQuery(recordType: "Subscriptions", predicate: predicate)
         DAOManager.instance?.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            print(results?.description)
             if error != nil {
                debugPrint("error fetching subscription", error!.localizedDescription)
                completion(nil)
                return
             }
            if results != nil  {
                for result in results! {
                    if result["user"] as? String == MeUser.instance.email {
                        completion(true)
                        return
                    }
                    print("=============", results?.description)
                    completion(false)
                    return
                }
            }
            completion(false)
        })
    }
    
    private func notificationInfo() -> CKSubscription.NotificationInfo {
        let info = CKSubscription.NotificationInfo()
        info.alertBody = "Você recebeu uma nova mensagem."
        info.shouldBadge = true
        info.soundName = "default"
        info.shouldSendContentAvailable = true
        return info
    }
    
    func registerChannelNotifications() {
        let predicate = NSPredicate(format: "fromStory = %@", MeUser.instance.email)
        let subscription = CKQuerySubscription(recordType: "Channel", predicate: predicate, options: .firesOnRecordCreation)
        let info = CKSubscription.NotificationInfo()
        info.title = "Você possui uma nova conversa!"
        info.alertBody = "Alguém criou uma nova conversa com você."
        info.shouldBadge = true
        info.soundName = "default"

        subscription.notificationInfo = info
        DAOManager.instance?.database.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
            } else {
                // Error occurred
            }
        })
    }
}
