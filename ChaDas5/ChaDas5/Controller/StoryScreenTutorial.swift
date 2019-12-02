//
//  StoryScreenTutorial.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 24/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit

class StoryScreenTutorial: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var chatBotButton: UIButton!
    
    @IBOutlet weak var dimissButton: UIButton!
    
    @IBAction func dismissButton(_ sender: Any) {
        
        dismiss()
    }
    
    override func viewDidLoad() {
        
        pulsate()
        
    }
    override func viewWillAppear(_ animated: Bool) {
      
        pulsate()
    }
    
    @objc private func dismiss() {
         self.dismiss(animated: true, completion: nil)

     }
    
    public func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.93
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 200
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        chatBotButton.layer.add(pulse, forKey: "pulseAnimation")
    }


}
