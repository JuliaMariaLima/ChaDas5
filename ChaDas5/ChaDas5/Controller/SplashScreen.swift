//
//  SplashScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 19/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import Firebase

class SplashScreen: UIViewController {
    
    //outlets
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var splashImage: UIImageView!
    
    override func viewDidLoad() {
        
//        print("USER 1:")
//        print(UserManager.instance.currentUser?.uid)
//
//        if Auth.auth().currentUser != nil {
//
//             self.performSegue(withIdentifier: "profile", sender: self)
//        }
//
//        else
//        {
//            self.animate()
//            Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SplashScreen.passScreen)), userInfo: nil, repeats: false)
//
//        }
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "profile", sender: self)
            } else {
                self.animate()
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SplashScreen.passScreen)), userInfo: nil, repeats: false)
            }
        }
       
        
    }
    
    func animate() {
        UIView.animate(withDuration: 1, animations: {
        
        self.splashView.frame.size.height = 434
            self.splashImage.frame.origin.y = 117
        
        
        }, completion: nil)
    }
    
    @objc func passScreen() {
        self.performSegue(withIdentifier: "goToMain", sender: self)
    }
    
    
}
