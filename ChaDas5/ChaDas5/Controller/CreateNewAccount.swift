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



class CreateNewAccount: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource
{
   

    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var createNewAccountButton: UIButton!
    
    @IBOutlet weak var cisWomanButton: UIButton!
    
    @IBOutlet weak var transWomanButton: UIButton!
    
    @IBOutlet weak var cisManButton: UIButton!
    
    @IBOutlet weak var transManButton: UIButton!
    
    @IBOutlet weak var otherButton: UIButton!
    
    @IBOutlet weak var noInfoButton: UIButton!
    
    @IBOutlet weak var pickerTeas: AKPickerView!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var activityView:UIActivityIndicatorView!
    var meUser: MeUser!
    var newAccountUserResquester: UserRequester!
    var identification: String!
    let allTeas = DAOManager.instance?.ckUsers.teas
    var yourTea:String!
    
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return allTeas!.count
           
    }
    
    func pickerView(_ pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        return UIImage(named: "picker_\(allTeas![item])")!.imageWithSize(CGSize(width: 120, height: 120))
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        yourTea = allTeas![item]
        
        previousButton.isHidden = (item == 0) ? true : false
        nextButton.isHidden = (item == allTeas!.count - 1) ? true : false
        
    }

    //actions
    
    @IBAction func prevButton(_ sender: Any) {
        
        self.pickerTeas.selectItem(self.pickerTeas.selectedItem - 1, animated: true)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        self.pickerTeas.selectItem(self.pickerTeas.selectedItem + 1, animated: true)
    }
    
    
    
    
    @IBAction func cisWomanAction(_ sender: Any) {
        cisWomanButton.backgroundColor = UIColor.middleOrange
        transWomanButton.backgroundColor = UIColor.clear
        cisManButton.backgroundColor = UIColor.clear
        transManButton.backgroundColor = UIColor.clear
        otherButton.backgroundColor = UIColor.clear
        noInfoButton.backgroundColor = UIColor.clear

        identification = "Mulher Cis"
    }
    
    @IBAction func transWomanAction(_ sender: Any) {
        
        cisWomanButton.backgroundColor = UIColor.clear
        transWomanButton.backgroundColor = UIColor.middleOrange
        cisManButton.backgroundColor = UIColor.clear
        transManButton.backgroundColor = UIColor.clear
        otherButton.backgroundColor = UIColor.clear
        noInfoButton.backgroundColor = UIColor.clear

        identification = "Mulher Trans"
  
    }
    
    
    @IBAction func cisManAction(_ sender: Any) {
        
      cisWomanButton.backgroundColor = UIColor.clear
      transWomanButton.backgroundColor = UIColor.clear
      cisManButton.backgroundColor = UIColor.middleOrange
      transManButton.backgroundColor = UIColor.clear
      otherButton.backgroundColor = UIColor.clear
      noInfoButton.backgroundColor = UIColor.clear

      identification = "Homem Cis"
        
    }
    
    
    @IBAction func transManAction(_ sender: Any) {
        
        cisWomanButton.backgroundColor = UIColor.clear
        transWomanButton.backgroundColor = UIColor.clear
        cisManButton.backgroundColor = UIColor.clear
        transManButton.backgroundColor = UIColor.middleOrange
        otherButton.backgroundColor = UIColor.clear
        noInfoButton.backgroundColor = UIColor.clear

        identification = "Homem Trans"
    }
    
    
    
    @IBAction func otherAction(_ sender: Any) {
        
        cisWomanButton.backgroundColor = UIColor.clear
        transWomanButton.backgroundColor = UIColor.clear
        cisManButton.backgroundColor = UIColor.clear
        transManButton.backgroundColor = UIColor.clear
        otherButton.backgroundColor = UIColor.middleOrange
        noInfoButton.backgroundColor = UIColor.clear

        identification = "Outro"

    }
    
    @IBAction func noInfoButton(_ sender: Any) {
        
        cisWomanButton.backgroundColor = UIColor.clear
        transWomanButton.backgroundColor = UIColor.clear
        cisManButton.backgroundColor = UIColor.clear
        transManButton.backgroundColor = UIColor.clear
        otherButton.backgroundColor = UIColor.clear
        noInfoButton.backgroundColor = UIColor.middleOrange

        identification = "Prefiro não dizer"

        
    }
    

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
            
            print(yourTea!)
            
            if (emailTextField.text?.contains("@"))!{
                meUser = MeUser(name: yourTea, email: emailTextField.text!, password: passwordTextField.text!, genderId: identification, blocked: [" "])
                
                print(self.meUser.name)
                
                DAOManager.instance?.ckUsers.save(newUser: meUser, requester: newAccountUserResquester)
                
            }else{
                let alert = UIAlertController(title: "", message: "O e-mail digitado não é válido", preferredStyle: UIAlertController.Style.alert)
                           alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                           alert.view.tintColor = UIColor.buttonOrange
                           
                           self.present(alert, animated: true, completion: nil)
                           emailTextField.text = ""
                           setcreateNewAccountButton(enabled: true)
                           createNewAccountButton.setTitle("Criar Conta", for: .normal)
                           activityView.stopAnimating()

            }
                
  
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

        passwordTextField?.isSecureTextEntry = true
        passwordConfirmationTextField.isSecureTextEntry = true
        emailTextField.textContentType = .emailAddress
        passwordTextField.textContentType = .password
        passwordConfirmationTextField.textContentType = .password
        yourTea = allTeas![0]
        
        pickerTeas.delegate = self
        pickerTeas.dataSource = self
        previousButton.isHidden = true

        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
           activityView = UIActivityIndicatorView(style: .gray)
        }
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
            self.otherButton.backgroundColor = UIColor.clear
            self.cisWomanButton.backgroundColor = UIColor.clear
            self.cisManButton.backgroundColor = UIColor.clear
            self.transWomanButton.backgroundColor = UIColor.clear
            self.transManButton.backgroundColor = UIColor.clear
            self.noInfoButton.backgroundColor = UIColor.clear
            self.identification = ""
           
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



extension CreateNewAccount: UserRequester {
    func saved(userRecord: CKRecord?, userError: Error?){
        if userRecord != nil {
            do{
                try meUser.save()
                print("salvouuuuuuuuuuuuu")
//                activityView.stopAnimating()
                if identification  == "Homem Cis"
                {
                    goTo(identifier: "cisMan")
                    MeUser.instance.delete()
                    DaoPushNotifications.instance.delete()
                    
                }else{
                     
                    goTo(identifier: "otherGroup")
                    
                }
                
            } catch {
                DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                                   
               let ok = UIAlertAction(title: "Ok", style: .default ) { (action) -> Void in
                   self.resetForm()
                   self.setcreateNewAccountButton(enabled: true)
                   self.createNewAccountButton.setTitle("Criar Conta", for: .normal)
                   self.activityView.stopAnimating()
                       
                }
               alert.addAction(ok)
               alert.view.tintColor = UIColor.buttonOrange
               self.present(alert, animated: true, completion: nil)
            }

            }
        }
    }
    
    func retrieved(user: User?, userError: Error?) {}
    
    func retrieved(userArray: [User]?, userError: Error?) {}
    
    func retrieved(meUser: MeUser?, meUserError: Error?) {}

    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
}


