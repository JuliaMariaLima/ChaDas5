//
//  Relato.swift
//  ChaDas5
//
//  Created by Julia Rocha on 06/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit

class Story : Codable {
    
    var content:String?
    var author:String?
    var date:String?
    var status:String?
    var isEnabled:Bool = true
    var id:String {
        if let date = self.date {
            if let author = self.author {
                return date+author
            }
        }
        return "error_creating_key"
    }

    init(conteudo:String, autor:String) {
        self.content = conteudo
        self.author = autor
        self.date = Date().keyString
        self.status = "active"
        save()
    }
    
    init?(from record:CKRecord) {
        guard let recordContent = record.object(forKey: "content") as? String else {
            return
        }
        guard let recordAuthor = record.object(forKey: "author") as? String else {
            return
        }
        guard let recordDate = record.object(forKey: "date") as? String else {
            return
        }
        guard let recordStatus = record.object(forKey: "status") as? String else {
            return
        }
        content = recordContent
        author = recordAuthor
        date = recordDate
        status = recordStatus
    }
    
//    var asDictionary:[String:Any] {
//        var result:[String:Any] = [:]
//        result["conteudo"] = self.content
//        result["autor"] = self.author
//        result["data"] = self.date
//        result["status"] = self.status
//        return result
//    }
    

    func save() {
        DAOManager.instance?.ckStories.save(story: self) { (result, error) in
            if error != nil {
                debugPrint("Error creating channel", String(describing: error?.localizedDescription))
            } else {
                debugPrint("Successfully saved story")
            }
        }
    }

    
}
    
