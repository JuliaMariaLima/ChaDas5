//
//  StoryScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import CloudKit



class PreChatBot: UIViewController {


    // MARK: -  View Configurations
    override func viewDidLoad() {
        //shadows to chatButton
        
    }
    

    @IBAction func chatButton(_ sender: Any) {
        DispatchQueue.main.async {
            let vc = ChatBotViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }

    
    
}
