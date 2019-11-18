//
//  Informations.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

class Informations: UIViewController {
    
    //main pages outlets
    @IBOutlet weak var whatToDoButton: UIButton!
    @IBOutlet weak var numbersButton: UIButton!
    @IBOutlet weak var informationsButton: UIButton!
    
    //what to do
    @IBAction func whatToDoDismissButton(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func numbersDismissButton(_ sender: Any) {
        self.dismiss()
    }
    @IBAction func informationDismissButton(_ sender: Any) {
        self.dismiss()
    }
    

    @IBAction func call1(_ sender: Any) {
        
        guard let number = URL(string: "tel://\(180)") else { return }
        UIApplication.shared.open(number)
        
    }
    
    
    @IBAction func call2(_ sender: Any) {
        guard let number = URL(string: "tel://\(190)") else { return }
        UIApplication.shared.open(number)
    }
    
    
    @IBAction func call3(_ sender: Any) {
        guard let number = URL(string: "tel://\(181)") else { return }
        UIApplication.shared.open(number)
    }
    
    
    @IBAction func call4(_ sender: Any) {
        guard let number = URL(string: "tel://\(100)") else { return }
        UIApplication.shared.open(number)
    
    }
    
    @IBAction func call5(_ sender: Any) {
        guard let number = URL(string: "tel://\(192)") else { return }
        UIApplication.shared.open(number)
        
    }
    
    
    @IBAction func call6(_ sender: Any) {
        guard let number = URL(string: "tel://\(193)") else { return }
        UIApplication.shared.open(number)
    }
    
    
    
    
    //dismiss func
    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
