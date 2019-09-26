//
//  User.swift
//  MeAcompanha
//
//  Created by Julia Maria Santos on 29/11/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation

class User: Codable {
    var name: String
    var email: String
    
    init(name: String,
         email: String) {
        self.name = name
        self.email = email
    }
}
