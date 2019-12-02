//
//  YourTea.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 02/12/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit

class YourTea: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource{
    
    var yourTeaName = "Default"
    let allTeas = DAOManager.instance?.ckUsers.teas
    
    
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
        yourTeaName = allTeas![item]
        
        previousButton.isHidden = (item == 0) ? true : false
        nextButton.isHidden = (item == allTeas!.count - 1) ? true : false
        
    }
    
    override func viewDidLoad() {
        pickerTeas.isHidden = true
        nextButton.isHidden = true
        previousButton.isHidden = true
        chooseYourTeaLabel.isHidden = true
        pickerTeas.delegate = self
        pickerTeas.dataSource = self
        continueButton.setTitle("Continuar", for: .normal)
        setContinueButton(enabled: false)
        //Tea image
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        
        yesButton.backgroundColor = .clear
        noButton.backgroundColor = .middleOrange
        pickerTeas.isHidden = false
        nextButton.isHidden = false
        previousButton.isHidden = false
        chooseYourTeaLabel.isHidden = false
        setContinueButton(enabled: true)
        
    }
    
    @IBAction func yesButtonAction(_ sender: Any) {
        
        yesButton.backgroundColor = .middleOrange
        noButton.backgroundColor = .clear
        pickerTeas.isHidden = true
        nextButton.isHidden = true
        previousButton.isHidden = false
        chooseYourTeaLabel.isHidden = true
        setContinueButton(enabled: true)
        //yourTeaName = allTeas![0]
        
        
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
         //salvar no banco o cha e fazer o segue
        
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

    
}
