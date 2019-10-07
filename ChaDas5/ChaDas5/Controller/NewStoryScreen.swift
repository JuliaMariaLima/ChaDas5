//
//  NewStoryScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

class NewStoryScreen: UIViewController, UITextViewDelegate {
    
    //outlets
    
    @IBOutlet weak var newStoryLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    
    
    
    //actions
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    @IBAction func sendButton(_ sender: Any) {
        
        _ = Story(conteudo: newStoryTextView.text)
        
        dismiss()
    }
    @IBOutlet weak var newStoryTextView: UITextView!
    
    override func viewDidLoad() {
        
        hideKeyboardWhenTappedAround()
        
        newStoryTextView.delegate = self
        
        newStoryLabel.textColor = UIColor.gray
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        newStoryLabel.text = ""
        newStoryTextView.text = String()
      
    }

    
    
    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
