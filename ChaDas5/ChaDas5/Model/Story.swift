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
    
    var content:String
    var author:String
    var date:String
    var status:String
    var isEnabled:Bool = true

    init(conteudo:String, autor:String) {
        self.content = conteudo
        self.author = autor
        self.date = Date().keyString
        self.status = "active"
        DAOManager.instance?.ckStories.save(story: self, completion: { (record, error) in
            if error != nil {
                debugPrint("error saving story - ", error.debugDescription)
            } else {
                debugPrint("successfully saved story")
            }
        })
    }
    
    init?(from record:CKRecord, completion: @escaping (Story?, String?) -> Void) {
        guard let recordContent = record["content"] as? String,
              let recordAuthor  = record["author"] as? String,
              let recordDate    = record["date"] as? String
//              let recordStatus  = record["status"] as? String
        else {
            completion(nil, NSError().description)
            return nil
        }
        self.content = recordContent
        self.author = recordAuthor
        self.date = recordDate
        self.status = "active"
        completion(self, nil)
    }
    
    var asCKRecord:CKRecord {
        let record = CKRecord(recordType: "Story")
        record.setObject(self.content as __CKRecordObjCValue, forKey: "content")
        record.setObject(self.author as __CKRecordObjCValue, forKey: "author")
        record.setObject(self.date as __CKRecordObjCValue, forKey: "date")
        record.setObject(self.status as __CKRecordObjCValue, forKey: "status")
        record.setObject(self.isEnabled as __CKRecordObjCValue, forKey: "isEnabled")
        return record
    }
    
}
    
