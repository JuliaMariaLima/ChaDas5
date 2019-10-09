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
    var blocked: [String] = []
    var isEmpty:Bool {
        return email.isEmpty
    }
    
    init(name: String = "",
         email: String = "",
         password: String = "",
         blocked: [String] = []) {
        
        self.password = password
        self.name = name
        self.email = email
        self.blocked = blocked

        // Quase um singleton, se criar uma nova instância, atualiza o .instance
        MeUser.instance = self
    }
}
