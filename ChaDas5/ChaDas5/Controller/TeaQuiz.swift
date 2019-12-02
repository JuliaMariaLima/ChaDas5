//
//  TeaQuiz.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 27/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit

class TeaQuiz: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var pickerView = UIPickerView()
    let toolBar = UIToolbar()
    let oldText = String()
    
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var numberLabel: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    
    var teaName:String = "Default"
    var answers = ["---","Discordo fortemente","Discordo", "Concordo", "Concordo Fortemente"]
    
   
    @objc func answersLabelTarget1(textField: UITextField) {
        pickerView.isHidden = false
        pickerView.autoresizingMask = .flexibleWidth
        answerField.text = oldText
    }
    
    @objc func doneTapped(button: UIBarButtonItem) {
        answerField.endEditing(true)
        if answerField.text != "---" && answerField.text != nil{
            setNextButton(enabled: true)
        } else {
            setNextButton(enabled: false)
        }

    }
    
    
    @objc func cancelTapped(button: UIBarButtonItem) {
        
        answerField.endEditing(true)
        answerField.text = oldText
   
    }

    // - MARK: Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return answers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return answers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
        answerField.text = answers[row]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        pickerView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        
        pickerView = UIPickerView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: 220.0)))
        view.addSubview(pickerView)
        pickerView.isHidden = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
 
        answerField.addTarget(self, action: #selector(answersLabelTarget1), for: .allTouchEvents)
        answerField.allowsEditingTextAttributes = false
        
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 59/255, green: 61/255, blue: 66/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor =  .buttonOrange
        doneButton.tintColor = .buttonOrange
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        answerField.inputView = pickerView
        answerField.inputAccessoryView = toolBar
        
        setNextButton(enabled: false)
         nextButton.setTitle("Próxima", for: .normal)
     
    }
    
    func calculate(){
        
        //change tea name
        
        
    }
    

    
    @IBAction func nextButtonAction(_ sender: Any) {
        setNextButton(enabled: false)
        nextButton.setTitle("", for: .normal)
        calculate()
        //mandar o cha pra outra tela e fazer o segue

    }
    


    
    func setNextButton(enabled:Bool) {
        if enabled {
            nextButton.alpha = 1.0
            nextButton.isEnabled = true
        } else {
            nextButton.alpha = 0.5
            nextButton.isEnabled = false
        }
    }
    
}
