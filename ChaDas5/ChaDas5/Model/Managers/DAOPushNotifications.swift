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

enum PushNotifications: String, Codable {
    case none
    case choose
    case video
    case confirm
    case found
    case finish
    case rate
    case cancel
}

class DaoPushNotifications: Codable {
    
    static var instance: DaoPushNotifications!
    var myState: PushNotifications = .none
    var partnerState: PushNotifications = .none
    var subscriptionId: CKSubscription.ID
    let notificationDescriptions: [PushNotifications:String] =
        [.choose : "Alguém quer te acompanhar!",
//         .video  : "O video deu certo!",
//         .confirm: "A pessoa confirmou!",
//         .found  : "Voces se encontraram!",
         .finish : "Sua companhia chegou no destino!",
//         .rate   : "Sua companhia te ranqueiou!",
         .cancel : "Sua companhia cancelou :("]

    
    init(myState: PushNotifications = .none,
         partnerState: PushNotifications = .none,
         subscriptionId: CKSubscription.ID = "") {
        self.subscriptionId = subscriptionId
        self.myState = myState
        self.partnerState = partnerState
        
        DaoPushNotifications.instance = self
    }

    
    /**
     Calls when wants to wait for the other woman to verify that in the video there's a woman
     
     - Parameter trip: the other woman's trip
     */
//    func caseConfirm(trip: Trip) {
//        DaoPushNotifications.instance.myState = .confirm
//        let predicate = NSPredicate(format: "id == %@", trip.id.uuidString)
//        createSubscription(recordType: "Trip", predicate: predicate, option: [.firesOnRecordUpdate, .firesOnce])
//    }
//
//    /**
//     Calls when wants to wait for the other woman to verify that they found each other
//
//     - Parameter trip: the other woman's trip
//     */
//    func caseFound(trip: Trip) {
//        DaoPushNotifications.instance.myState = .found
//        let predicate = NSPredicate(format: "id == %@", trip.id.uuidString)
//        createSubscription(recordType: "Trip", predicate: predicate, option: [.firesOnRecordUpdate, .firesOnce])
//    }
//
//    /**
//     Calls when wants to wait for the other woman to verify that she finished the trip
//
//     - Parameter trip: the other woman's trip
//     */
//    func caseFinish(trip: Trip) {
//        DaoPushNotifications.instance.myState = .finish
//        let predicate = NSPredicate(format: "id == %@", trip.id.uuidString)
//        createSubscription(recordType: "Trip", predicate: predicate, option: [.firesOnRecordUpdate, .firesOnce])
//    }
//
//    /**
//     Calls when wants to wait for the other woman to rate
//
//     - Parameter trip: the current user trip
//     */
//    func caseRate(trip: Trip) {
//        DaoPushNotifications.instance.myState = .rate
//        let predicate = NSPredicate(format: "id == %@", trip.id.uuidString)
//        createSubscription(recordType: "Trip", predicate: predicate, option: [.firesOnRecordUpdate, .firesOnce])
//    }

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
//                SharedTrip.instance.delete()
                self.subscriptionId = ""
                self.myState = .none
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
    
//    private func notification(for pushNotificationType: PushNotifications) -> CKSubscription.NotificationInfo {
//        let info = CKSubscription.NotificationInfo()
//        info.alertBody = String(describing: pushNotificationType) + "|" + notificationDescriptions[pushNotificationType]!
//        info.shouldBadge = true
//        info.soundName = "default"
//        return info
//    }
}
//
//extension DaoPushNotifications: TripRequester {
//    func saved(tripRecord: CKRecord?, tripError: Error?) {}
//
//    func retrieved(trip: Trip?, localReference: CKRecord.Reference?, busReference: CKRecord.Reference?, tripError: Error?, fromUserEmail: String, fromIndex: Int) {
//        if trip != nil {
//            MeUser.instance.avaliation.append(trip!.avaliation)
//            DAOCloudKit.instance?.ckUsers.edit(meUser: MeUser.instance, emergencyContactRecord: nil, currentTripRecord: nil, previousTripsRecord: nil, requester: self)
//        }
//    }
//
//    func retrieved(tripReference: CKRecord.Reference?, tripError: Error?, fromUserEmail: String) {}
//    func retrieved(previousTripsReference: [CKRecord.Reference]?, tripError: Error?) {}
//}

extension DaoPushNotifications: UserRequester {
    func saved(userRecord: CKRecord?, userError: Error?) {
        if userRecord != nil {
            if myState != .cancel {
                print("acho q deu tudo certo")
                do { try MeUser.instance.save()
                    
                } catch {
                    print("erro salvando me user")
                    let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    alert.present(CreateNewAccount(), animated: true, completion: nil)
                    alert.present(Login(), animated: true, completion: nil)
                }
            } else {
                print("viagem cancelada com sucesso")

                do { try MeUser.instance.save()
                    
                } catch {
                    print("erro")
                    let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    alert.present(CreateNewAccount(), animated: true, completion: nil)
                    alert.present(Login(), animated: true, completion: nil)
                }
            }
        }
    }
    
    func retrieved(user: User?, userError: Error?) {}
    func retrieved(userArray: [User]?, userError: Error?) {}
    func retrieved(meUser: MeUser?, meUserError: Error?) {}
    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
}
