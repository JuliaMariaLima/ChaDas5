//
//  NewStoryScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

// MARK: -  Declaration
class NewStoryScreen: UIViewController, UITextViewDelegate {
    
    // MARK: -  Outlets
    @IBOutlet weak var newStoryLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: -  View Configurations
    override func viewDidLoad() {
        
        hideKeyboardWhenTappedAround()
        
        newStoryTextView.delegate = self
        
        newStoryLabel.textColor = UIColor.gray
        
    }
    
    // MARK: -  Actions
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    @IBAction func sendButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Seu relato possui conteúdo sensível?", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Sim", style: .default, handler: { (action) -> Void in
            
            let story = Story(conteudo: self.newStoryTextView.text, gatilho: 5)
//            self.sendForAnalysis(input: story)
            self.dismiss()
        })
        
        let no = UIAlertAction(title: "Não", style: .default, handler: { (action) -> Void in
                
            let story = Story(conteudo: self.newStoryTextView.text, gatilho: 0)
//            self.sendForAnalysis(input: story)
            self.dismiss()
            })
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel ) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange
        
    }
//
//    func sendForAnalysis(input: Story) {
//        DAOManager.instance?.ckAnalysisLog.classifyInput(with: input.content, on: input.date, with: self)
//    }
    
    @IBOutlet weak var newStoryTextView: UITextView!
    
    // MARK: -  Text Field
    func textViewDidBeginEditing(_ textView: UITextView) {
        newStoryLabel.text = ""
        newStoryTextView.text = String()
      
    }

    
    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//// MARK: -  Extentions
//
//// MARK: -  AnalysisLogProtocol extention
//extension NewStoryScreen: AnalysisLogProtocol {
//
//    func createdAnalysisLog() {
//
//    }
//
//    func retrievedAnalysisLog(with analysisLog: AnalysisLog) {
//
//    }
//
//    func updatedAnalysisLog() {
//        debugPrint("successfully updated")
//    }
//
//    func createdAnalysisLog(with error: Error) {
//
//    }
//
//    func retrievedAnalysisLog(with error: Error) {
//
//    }
//
//    func updatedAnalysisLog(with error: Error) {
//        debugPrint(error)
//    }
//
//
//}
