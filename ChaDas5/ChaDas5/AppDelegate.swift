//
//  AppDelegate.swift
//  ChaDas5
//
//  Created by Julia Maria Santos on 26/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            try MeUser.instance.load()
            print("vai p tela do mapa")
            print(MeUser.instance.email)
            // first responder default
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            
            let initialViewController = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } catch {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "SplashScreen", bundle: nil)
            
            let initialViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = initialViewController
                  self.window?.makeKeyAndVisible()
            
            print("Se cadastra, porra!")
            // first responder login
        }
        
            if DaoPushNotifications.instance == nil {
            let dao = DaoPushNotifications.init()
            debugPrint(dao)
            do { try DaoPushNotifications.instance.save() }
            catch {
                print("nao foi aqui")
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                alert.present(CreateNewAccount(), animated: true, completion: nil)
                alert.present(Login(), animated: true, completion: nil)
            }
        }
        
        do { try DaoPushNotifications.instance.load()
            
        } catch {
            print("nao foi anyway")
            let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            alert.present(CreateNewAccount(), animated: true, completion: nil)
            alert.present(Login(), animated: true, completion: nil)
        }
          
          // set self (AppDelegate) to handle notification
          UNUserNotificationCenter.current().delegate = self

          // Request permission from user to send notification
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
              DispatchQueue.main.async(execute: {
                application.registerForRemoteNotifications()
              })
            }
          })
          
          return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // This function will be called when the app receive notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
      // show the notification alert (banner), and with sound
      completionHandler([.alert, .sound])
    }
    
    // This function will be called right after user tap on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      
      // tell the app that we have finished processing the user’s action (eg: tap on notification banner) / response
      completionHandler()
    }
   
    
//    // AppDelegate.swift
//
//    // When user allowed push notification and the app has gotten the device token
//        // (device token is a unique ID that Apple server use to determine which device to send push notification to)
//        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//            // Create a subscription to the 'Notifications' Record Type in CloudKit
//            // User will receive a push notification when a new record is created in CloudKit
//            // Read more on https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/SubscribingtoRecordChanges/SubscribingtoRecordChanges.html
//
//            // The predicate lets you define condition of the subscription, eg: only be notified of change if the newly created notification start with "A"
//            // the TRUEPREDICATE means any new Notifications record created will be notified
//            let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
//
//            // Here we customize the notification message
//            let info = CKSubscription.NotificationInfo()
//
//            // this will use the 'title' field in the Record type 'notifications' as the title of the push notification
//            info.titleLocalizationKey = "%1$@"
//            info.titleLocalizationArgs = ["title"]
//
//            // if you want to use multiple field combined for the title of push notification
//            // info.titleLocalizationKey = "%1$@ %2$@" // if want to add more, the format will be "%3$@", "%4$@" and so on
//            // info.titleLocalizationArgs = ["title", "subtitle"]
//
//            // this will use the 'content' field in the Record type 'notifications' as the content of the push notification
//            info.alertLocalizationKey = "%1$@"
//            info.alertLocalizationArgs = ["content"]
//
//            // increment the red number count on the top right corner of app icon
//            info.shouldBadge = true
//
//            // use system default notification sound
//            info.soundName = "default"
//
//            subscription.notificationInfo = info
//
//            // Save the subscription to Public Database in Cloudkit
//            DAOManager.instance?.database.save(subscription, completionHandler: { subscription, error in
//                if error == nil {
//                    // Subscription saved successfully
//                } else {
//                    // Error occurred
//                }
//            })
//
//        }
    
}
