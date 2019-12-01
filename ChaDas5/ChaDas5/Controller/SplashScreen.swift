//
//  SplashScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 19/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

// MARK: -  Declaration
class SplashScreen: UIViewController {
    
    // MARK: -  Outlets
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var splashImage: UIImageView!
    var window: UIWindow?
    
    
    // MARK: -  View Configurations
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
       animate()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SplashScreen.passScreen)), userInfo: nil, repeats: false)
        
    }
    
    // MARK: -  Animation
    func animate() {
        UIView.animate(withDuration: 1, animations: {
        self.splashView.frame.size.height = 434
        self.splashImage.frame.origin.y = 117
        }, completion: nil)
    }
    
    // MARK: -  Segue
    @objc func passScreen() {
        self.performSegue(withIdentifier: "goToMain", sender: self)
    }
    
    
}
