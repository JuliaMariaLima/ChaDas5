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
import ApiAI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let configuration = AIDefaultConfiguration()
        configuration.clientAccessToken = "504f38a4a1294b3eb4fa95d9966cffb9"

        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        apiai?.lang = "pt-BR"


        do {
            try MeUser.instance.load()
            // first responder default
            self.window = UIWindow(frame: UIScreen.main.bounds)

            let storyboard:UIStoryboard?
            print(MeUser.instance.email)
            if MeUser.instance.name == "Default" {
                storyboard = UIStoryboard(name: "TeaQuiz", bundle: nil)
            }else{
                if MeUser.instance.tutorial != "Done"{
                      storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
                } else {
                      storyboard = UIStoryboard(name: "Profile", bundle: nil)
                }
            }

            let initialViewController = storyboard!.instantiateInitialViewController()

            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } catch {
            self.window = UIWindow(frame: UIScreen.main.bounds)

            // Change to SplashScreen
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

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let operation = CKModifyBadgeOperation(badgeValue: 0)
        operation.modifyBadgeCompletionBlock = {(error) in
            if let error = error{
                print("\(error)")
                return
            }
            DispatchQueue.main.async {
                application.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(operation)
    }
}
