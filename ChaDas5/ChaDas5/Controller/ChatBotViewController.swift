//
//  ChatBotViewController.swift
//  ChaDas5
//
//  Created by Julia Rocha on 27/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit
import ApiAI


class ChatBotViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var insertText: UITextField!
    
    
    @IBOutlet weak var sendForAPI: UIButton!
    
    @IBOutlet weak var reponseLabel: UILabel!
    
    @IBAction func sendForAPI(_ sender: Any) {
        sendText(with: insertText.text ?? "")
    }
    
    
    func sendText(with text:String) {
        
        let request = ApiAI.shared().textRequest()
        if text != "" {
             request?.query = text
         } else { return }
         request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            
            // check
            if let textResponse = response.result.fulfillment.messages.first {
//             print(textResponse)
                self.reponseLabel.text = textResponse["speech"] as? String
                
         }
         }, failure: { (request, error) in
             print(error!)
         })
         ApiAI.shared().enqueue(request)
        // esvaziar caixa de resposta
        insertText.text = ""
    }
    
}
