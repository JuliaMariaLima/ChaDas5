//
//  MeUser.swift
//  MeAcompanha
//
//  Created by Julia Maria Santos on 04/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit

class MeUser: Codable {
    
    static var instance: MeUser!
    var password: String
    var name: String
    var email: String
    var genderId: String
    var tutorial: String
    var birthDate: String
    var blocked: [String]
    var isEmpty:Bool {
        return email.isEmpty
    }
    
    init(name: String = "",
         email: String = "",
         password: String = "",b
         genderId: String = "",
         tutorial: String = "",
         birthDate: String = "",
         blocked: [String] ) {
        
        self.password = password
        self.name = name
        self.email = email
        self.genderId = genderId
        self.tutorial = tutorial
        self.blocked = blocked
        self.birthDate = birthDate

        // Quase um singleton, se criar uma nova instância, atualiza o .instance
        MeUser.instance = self
    }
}
