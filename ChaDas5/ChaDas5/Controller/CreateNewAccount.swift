//
//  CreateNewAccount.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit
import Foundation
import CloudKit



class CreateNewAccount: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

    var selected:ChooseYourTeaCollectionViewCell?
    var index: IndexPath?

    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var pickYourTeaCollectionView: UICollectionView!
    @IBOutlet weak var createNewAccountButton: UIButton!

    var activityView:UIActivityIndicatorView!
    var meUser: MeUser!
    var newAccountUserResquester: UserRequester!

    //actions
    @IBAction func createNewButton(_ sender: Any) {
        
        newAccountUserResquester = self
        setcreateNewAccountButton(enabled: false)
        activityView.center = self.createNewAccountButton.center
        createNewAccountButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        if passwordTextField.text != passwordConfirmationTextField.text{
            let alert = UIAlertController(title: "", message: "Erro na Confirmação de Senha", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            passwordTextField.text = ""
            alert.view.tintColor = UIColor.buttonOrange
            passwordConfirmationTextField.text = ""
            setcreateNewAccountButton(enabled: true)
            createNewAccountButton.setTitle("Criar Conta", for: .normal)
            activityView.stopAnimating()
            
        }
    
        if checkPassword(password1: passwordTextField.text!, password2: passwordConfirmationTextField.text!) {
        
            print("Entrou")
            meUser = MeUser(name: selected!.chooseYourTeaLabel.text!, email: emailTextField.text!, password: passwordTextField.text!, blocked: [])
            DAOManager.instance?.ckUsers.save(newUser: meUser, requester: newAccountUserResquester)
        } else {
            let alert = UIAlertController(title: "", message: "Reveja a sua senha, ela tem que ter no mínimo 8 caracteres", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            alert.view.tintColor = UIColor.buttonOrange
            
            self.present(alert, animated: true, completion: nil)
            passwordTextField.text = ""
            passwordConfirmationTextField.text = ""
            setcreateNewAccountButton(enabled: true)
            createNewAccountButton.setTitle("Criar Conta", for: .normal)
            activityView.stopAnimating()
            
        }


    }
    
    
    
    

    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }

    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()

        passwordTextField.isSecureTextEntry = true
        passwordConfirmationTextField.isSecureTextEntry = true
        emailTextField.textContentType = .emailAddress
        passwordTextField.textContentType = .password
        passwordConfirmationTextField.textContentType = .password
        
        //collection view settings
        pickYourTeaCollectionView.allowsMultipleSelection = false
        pickYourTeaCollectionView.dataSource = self
        pickYourTeaCollectionView.delegate = self
        pickYourTeaCollectionView.allowsSelection = true
        pickYourTeaCollectionView.bounds.inset(by: pickYourTeaCollectionView.layoutMargins)
        let nib = UINib.init(nibName: "ChooseYourTeaCollectionViewCell", bundle: nil)
        self.pickYourTeaCollectionView.register(nib, forCellWithReuseIdentifier: "PickYouTea")

        activityView = UIActivityIndicatorView(style: .medium)
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = self.createNewAccountButton.center

        view.addSubview(activityView)

        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordConfirmationTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        setcreateNewAccountButton(enabled: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordConfirmationTextField.resignFirstResponder()

        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .lightContent }
    }

    @objc func keyboardWillAppear(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        createNewAccountButton.center = CGPoint(x: view.center.x,
                                                y: view.frame.height - keyboardFrame.height - 16.0 - createNewAccountButton.frame.height / 2)
        activityView.center = createNewAccountButton.center
    }


    // MARK: - CollectionView Settings
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (DAOManager.instance?.ckUsers.teas.count)!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pickYouTeaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickYouTea", for: indexPath) as! ChooseYourTeaCollectionViewCell
        pickYouTeaCell.chooseYourTeaLabel.text = DAOManager.instance?.ckUsers.teas[indexPath.item]
        pickYouTeaCell.chooseYourteaImage.image = UIImage(named:  (DAOManager.instance?.ckUsers.teas[indexPath.item]) ?? "")
        pickYouTeaCell.chooseYourteaImage.contentMode = UIView.ContentMode.scaleAspectFit
        return pickYouTeaCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChooseYourTeaCollectionViewCell
        selectedCell.contentView.backgroundColor = UIColor.baseOrange
        self.selected = selectedCell
        self.index = collectionView.indexPath(for: selected!)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as? ChooseYourTeaCollectionViewCell
        selectedCell?.contentView.backgroundColor = UIColor.white
    }

    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailTextField.text
        let passwordConfirmed = passwordConfirmationTextField.text
        let password = passwordTextField.text

        let formFilled = email != nil && email != "" && passwordConfirmed != nil && passwordConfirmed != "" && password != nil && password != ""
        setcreateNewAccountButton(enabled: formFilled)
    }



    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            passwordConfirmationTextField.becomeFirstResponder()
            break
        case passwordConfirmationTextField:
            break
        default:
            break
        }
        return true
    }


    func resetForm() {
        let tentarNovamente = UIAlertAction(
            title: "Tentar Novamente",
            style: .default,
            handler: { (action) -> Void in
            self.emailTextField.text = ""
            self.passwordConfirmationTextField.text = ""
            self.passwordTextField.text = ""
            self.pickYourTeaCollectionView.deselectItem(at: self.index!, animated: true)
        })

        let cancelar = UIAlertAction(title: "Cancelar", style: .default ) { (action) -> Void in
            self.dismiss()
        }

        let alert = UIAlertController(
            title: "Oops...",
            message: "Ocorreu algum erro com seus dados",
            preferredStyle: .alert)
        alert.addAction(tentarNovamente)
        alert.addAction(cancelar)
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.buttonOrange

        setcreateNewAccountButton(enabled: true)
        createNewAccountButton.setTitle("Criar Conta", for: .normal)
        activityView.stopAnimating()
    }




    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)

    }

    func checkPassword(password1: String, password2: String) -> Bool {
        guard password1.count >= 8 else { return false }
        return password1 == password2 ? true : false
    }

    func goTo(identifier: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }


    /**
     Enables or Disables the **continueButton**.
     */

    func setcreateNewAccountButton(enabled:Bool) {
        activityView.center = self.createNewAccountButton.center
        if enabled {
            createNewAccountButton.alpha = 1.0
            createNewAccountButton.isEnabled = true
        } else {
            createNewAccountButton.alpha = 0.5
            createNewAccountButton.isEnabled = false
        }
    }

    
}

extension UICollectionView {

    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}



extension CreateNewAccount: UserRequester {
    func saved(userRecord: CKRecord?, userError: Error?){
        if userRecord != nil {
            do{
                try meUser.save()
                activityView.stopAnimating()
                goTo(identifier: "Feed")
                print("salvouuuuuuuuuuuuu")
            } catch {
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                alert.view.tintColor = UIColor.buttonOrange
                self.present(alert, animated: true, completion: nil)
                print("erro ao salvar local nova conta")
                self.setcreateNewAccountButton(enabled: true)
                self.createNewAccountButton.setTitle("Criar Conta", for: .normal)
                self.activityView.stopAnimating()
            }
        }
    }
    
    func retrieved(user: User?, userError: Error?) {}
    
    func retrieved(userArray: [User]?, userError: Error?) {}
    
    func retrieved(meUser: MeUser?, meUserError: Error?) {}

    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
}


