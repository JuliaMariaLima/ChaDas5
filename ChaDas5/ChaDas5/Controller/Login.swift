//
//  Login.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


class Login: UIViewController {

    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var loginUserRequester: UserRequester!
    var password: String!
    var meUser: MeUser!


    var activityView:UIActivityIndicatorView!

    //action
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        setLoginButton(enabled: false)
        activityView.center = loginButton.center
        loginButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
         
        loginUserRequester = self as UserRequester
        DAOManager.instance?.ckUsers.get(meFromEmail: emailTextField.text!, requester: loginUserRequester)
        MeUser.instance = self.meUser
        password = passwordTextField.text!
        loginButton.isEnabled = false

    }

    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
        passwordTextField.isSecureTextEntry = true

        if #available(iOS 13.0, *) {
            activityView = UIActivityIndicatorView(style: .medium)
        } else {
            activityView = UIActivityIndicatorView(style: .gray)
        }
        activityView.color = UIColor.buttonOrange
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = loginButton.center

        view.addSubview(activityView)

        emailTextField.delegate = self as? UITextFieldDelegate
        passwordTextField.delegate = self as? UITextFieldDelegate
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        setLoginButton(enabled: false)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.becomeFirstResponder()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    @objc func keyboardWillAppear(notification: NSNotification){

        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        loginButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - loginButton.frame.height / 2)
        activityView.center = self.loginButton.center
    }

    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        setLoginButton(enabled: formFilled)
    }


    func resetForm() {

        emailTextField.text = ""
        passwordTextField.text = ""
        loginButton.setTitle("Fazer Login", for: .normal)
        activityView.stopAnimating()
    }

    @objc private func dismiss() {
        self.dismiss(animated: true, completion: nil)

    }


    func setLoginButton(enabled:Bool) {
        activityView.center = loginButton.center
        if enabled {
            loginButton.alpha = 1.0
            loginButton.isEnabled = true
        } else {
            loginButton.alpha = 0.5
            loginButton.isEnabled = false
        }
    }
    
 
    func goTo(identifier: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
}

extension Login: UserRequester {
    
    func retrieved(user: User?, fromIndex: Int, userError: Error?) {}
    
    func saved(userRecord: CKRecord?, userError: Error?) {}
    
    func retrieved(user: User?, userError: Error?) {}
    
    func retrieved(meUser: MeUser?, meUserError: Error?) {
        if meUser != nil {
            print("UHUL")
            if meUser!.password == password {
                MeUser.instance = meUser
                
                do { try! MeUser.instance.save() }

                print("sucesso login")
                DispatchQueue.main.async {
                    self.activityView.stopAnimating()
                }
                
                if meUser!.genderId == "Homem Cis"
                {
                    goTo(identifier: "cisMan")
                    MeUser.instance.delete()
                    DaoPushNotifications.instance.delete()
                    
                } else if meUser!.genderId != "Homem Cis" && meUser!.name == "Default"{
                    goTo(identifier: "Quiz")
                }else if meUser!.genderId != "Homem Cis" && meUser!.tutorial == "Done"{
                    goTo(identifier: "Feed")
                }else{
                    goTo(identifier: "Tutorial")
                }
                
                
            } else{
                // erro
                print("deu ruim")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Sua senha ou email estão errados.", preferredStyle: UIAlertController.Style.alert)
                    let ok = UIAlertAction(title: "Ok", style: .default ) { (action) -> Void in
                        self.resetForm()
                        self.setLoginButton(enabled: true)
                        self.loginButton.setTitle("Criar Conta", for: .normal)
                        self.activityView.stopAnimating()
                                
                         }

                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    alert.view.tintColor = UIColor.buttonOrange
                }
                
                
    
            }
        } else if meUserError != nil {
            // nao tem cadastro
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "Ocorreu um erro inesperado", preferredStyle: UIAlertController.Style.alert)
                let ok = UIAlertAction(title: "Ok", style: .default ) { (action) -> Void in
                    self.resetForm()
                    self.setLoginButton(enabled: true)
                    self.loginButton.setTitle("Criar Conta", for: .normal)
                    self.activityView.stopAnimating()
                        
                 }
                alert.addAction(ok)
                alert.view.tintColor = UIColor.buttonOrange
                self.present(alert, animated: true, completion: nil)
                
            }

        }
    }
    
    func retrieved(userArray: [User]?, userError: Error?) {}
}


