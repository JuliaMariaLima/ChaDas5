//
//  YourTea.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 02/12/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class YourTea: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource{
    
    var yourTeaName = "Default"
    var oldTeaName = ""
    var isFirst = 0
    let allTeas = DAOManager.instance?.ckUsers.teas
    
    var userRequester: UserRequester!
    var meUser: MeUser!
    
    @IBOutlet weak var teaImage: UIImageView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var pickerTeas: AKPickerView!
    @IBOutlet weak var chooseYourTeaLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return allTeas!.count
        
    }
    
    func pickerView(_ pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        return UIImage(named: "picker_\(allTeas![item])")!.imageWithSize(CGSize(width: 120, height: 120))
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
       
        if item == 0{
            isFirst = 1
        }else if item == (allTeas!.count)-1{
            isFirst = 3
            
        }else{
            isFirst = 2
        }
       
        yourTeaName = allTeas![item]
        previousButton.isHidden = (item == 0) ? true : false
        nextButton.isHidden = (item == allTeas!.count - 1) ? true : false
        
    }
    
    override func viewDidLoad() {
        pickerTeas.isHidden = true
        nextButton.isHidden = true
        chooseYourTeaLabel.isHidden = true
        previousButton.isHidden = true
        pickerTeas.delegate = self
        pickerTeas.dataSource = self
        continueButton.setTitle("Continuar", for: .normal)
        setContinueButton(enabled: false)
        oldTeaName = yourTeaName
        teaImage.image = UIImage(named: "picker_\(yourTeaName)")
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        
        yesButton.backgroundColor = .clear
        noButton.backgroundColor = .middleOrange
        chooseYourTeaLabel.isHidden = true
        pickerTeas.isHidden = true
        nextButton.isHidden = true
        previousButton.isHidden = true
        setContinueButton(enabled: true)
        yourTeaName = oldTeaName
        
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        
        yesButton.backgroundColor = .middleOrange
        noButton.backgroundColor = .clear
        chooseYourTeaLabel.isHidden = false
        pickerTeas.isHidden = false
        setContinueButton(enabled: true)
        if isFirst == 1 || isFirst == 0 {
            previousButton.isHidden = true
            nextButton.isHidden = false
            yourTeaName = allTeas![0]
        }else if isFirst == 3{
            previousButton.isHidden = false
            nextButton.isHidden = true
        }else{
            previousButton.isHidden = false
            nextButton.isHidden = false
        }
        
    }
    
    @IBAction func previousButtonAction(_ sender: Any) {
        self.pickerTeas.selectItem(self.pickerTeas.selectedItem - 1, animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        self.pickerTeas.selectItem(self.pickerTeas.selectedItem + 1, animated: true)
    }
    
    
    @IBAction func continueButtonAction(_ sender: Any) {
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        
        userRequester = self
        
         meUser = MeUser(name: yourTeaName, email: MeUser.instance.email, password: MeUser.instance.password, blocked: MeUser.instance.blocked)
         DAOManager.instance?.ckUsers.edit(meUser: meUser, requester: userRequester)
         MeUser.instance = meUser
         do {
          try MeUser.instance.save()
          try MeUser.instance.load()
         }
         catch {
          print("Erro ao Salvar")
          let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
          let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                              
              self.dismiss()
              
          })
          alert.addAction(ok)
          self.present(alert, animated: true, completion: nil)
         }
            
        performSegue(withIdentifier: "tutorial", sender: nil)

    }
    
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)
        
    }

    
}

extension YourTea: UserRequester {
    // pra editar
    func saved(userRecord: CKRecord?, userError: Error?) {
        if userRecord != nil {
            print("user novo salvou")
            do{
                try meUser.save()
                print("salvouuuuuuuuuuuuu")
            } catch {
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("erro ao salvar local nova conta")
            }
        }
    }
    
    func retrieved(user: User?, userError: Error?) {}
    
    func retrieved(userArray: [User]?, userError: Error?) {}
    
    func retrieved(meUser: MeUser?, meUserError: Error?) {}

    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
}

