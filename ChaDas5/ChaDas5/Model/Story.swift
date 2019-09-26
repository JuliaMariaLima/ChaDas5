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
    
    init?(from record:CKRecord) {
        guard let recordContent = record.object(forKey: "content") as? String,
              let recordAuthor  = record.object(forKey: "author") as? String,
              let recordDate    = record.object(forKey: "date") as? String,
              let recordStatus  = record.object(forKey: "status") as? String
        else {
            return nil
        }
        content = recordContent
        author = recordAuthor
        date = recordDate
        status = recordStatus
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
    
