//
//  ConfigurationsPopUpViewController.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 03/10/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import UIKit

class ConfigurationsPopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        self.showAnimate()
        
        ///Shadows
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0)
        popUpView.layer.shadowColor = UIColor.black.cgColor
        popUpView.layer.shadowOpacity = 0.23
        popUpView.layer.shadowRadius = 4
        popUpView.layer.cornerRadius = 25

    }
    

    @IBAction func closePopUp(_ sender: Any) {
        
        self.removeAnimate()
        
    }
    
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
    @IBAction func notificationsSwitcher(_ sender: Any) {
        
        
        
        
    }
    
}
