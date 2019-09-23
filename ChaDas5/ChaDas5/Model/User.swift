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
    var id: String
    
    init(name: String,
         id: String) {
        
        self.name = name
        self.id = id
    }
}
