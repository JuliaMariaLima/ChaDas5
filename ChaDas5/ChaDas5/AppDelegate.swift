//
//  AppDelegate.swift
//  ChaDas5
//
//  Created by Julia Maria Santos on 26/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import UserNotifications

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
        
        let notificationManager = NotificationsManager()
        notificationManager.registerForLocalNotifications()
        return true
    }
    

    
    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
    
   
    
}

