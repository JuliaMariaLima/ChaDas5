//
//  ChooseYourTeaScreen.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 08/01/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import  UIKit
import Foundation
import CloudKit

class ChooseYourTeaScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
   
    @IBOutlet weak var salvar: UIButton!
    
    @IBOutlet weak var chooseYourTeaCollectionView: UICollectionView!
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    
    var selected:ChooseYourTeaCollectionViewCell?
    var chooseYourTeaUserResquester: UserRequester!
    var meUser: MeUser!
    var index: IndexPath?
    
    
    var pickYourTeaCell: ChooseYourTeaCollectionViewCell?
    
    override func viewDidLoad() {
        //collection view settings
        chooseYourTeaCollectionView.allowsMultipleSelection = false
        chooseYourTeaCollectionView.dataSource = self
        chooseYourTeaCollectionView.delegate = self
        chooseYourTeaCollectionView.allowsSelection = true
        chooseYourTeaCollectionView.bounds.inset(by: chooseYourTeaCollectionView.layoutMargins)
        let nib = UINib.init(nibName: "ChooseYourTeaCollectionViewCell", bundle: nil)
        self.chooseYourTeaCollectionView.register(nib, forCellWithReuseIdentifier: "PickYouTea")
        salvar.alpha = 0.5
        salvar.isEnabled = false
    }
    
    //collection view settings
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (DAOManager.instance?.ckUsers.teas.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pickYouTeaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickYouTea", for: indexPath) as! ChooseYourTeaCollectionViewCell
        pickYouTeaCell.chooseYourTeaLabel.text = DAOManager.instance?.ckUsers.teas[indexPath.item]
        pickYouTeaCell.chooseYourteaImage.image = UIImage(named:  (DAOManager.instance?.ckUsers.teas[indexPath.item])!)
        pickYouTeaCell.chooseYourteaImage.contentMode = UIView.ContentMode.scaleAspectFit
        return pickYouTeaCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChooseYourTeaCollectionViewCell
        selectedCell.contentView.backgroundColor = UIColor.baseOrange
        self.selected = selectedCell
        salvar.alpha = 1
        salvar.isEnabled = true
        self.index = collectionView.indexPath(for: selected!)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? ChooseYourTeaCollectionViewCell
        selectedCell?.contentView.backgroundColor = UIColor.white
    }
    
    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func salvar(_ sender: Any) {
        
       chooseYourTeaUserResquester = self
       guard let yourTea = self.selected!.chooseYourTeaLabel.text else { return }
      
       meUser = MeUser(name: yourTea, email: MeUser.instance.email, password: MeUser.instance.password, blocked: MeUser.instance.blocked)
       DAOManager.instance?.ckUsers.edit(meUser: meUser, requester: chooseYourTeaUserResquester)
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

        self.dismiss()
       
    }
    
}


extension ChooseYourTeaScreen: UserRequester {
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

