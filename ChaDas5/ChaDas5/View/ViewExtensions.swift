//
//  ViewExtensions.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 01/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import UIKit

extension UIColor {
    static let baseOrange = UIColor(red:252.0/255.0, green: 249.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    static let buttonOrange = UIColor(red:241.0/255.0, green: 155.0/255.0, blue: 116.0/255.0, alpha: 1.0)
    static let middleOrange = UIColor(red: 248.0/255.0, green: 206.0/255.0, blue: 160.0/255.0, alpha: 1.0)
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
