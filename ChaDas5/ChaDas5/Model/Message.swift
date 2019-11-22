//
//  ChannelsManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 03/01/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import CloudKit
import MessageKit


struct Message: MessageType {
    

    var id: String?
    var content: String
    var sentDate: Date
    var senderID: String
    var senderDisplayName: String
    var onChannel: String
    var kind: MessageKind
    var sender: SenderType
    
    var messageId: String {
        return id ?? UUID().uuidString
    }

    
    init(content: String, on channel: String) {
        self.senderID = MeUser.instance.email
        self.senderDisplayName = MeUser.instance.name
        self.content = content
        onChannel = channel
        sentDate = Date()
        kind = .text(content)
        sender = Sender(id: senderID, displayName: senderDisplayName)
        id = nil
    }
    
    init?(from record:CKRecord, completion: @escaping (Message?, String?) -> Void) {
        guard let recordContent  = record.object(forKey: "content") as? String,
              let recordDate     = record.object(forKey: "sentDate") as? Date,
              let recordSenderID = record.object(forKey: "senderID") as? String,
              let recordSenderDisplayName = record.object(forKey: "senderDisplayName") as? String,
              let recordChannel  = record.object(forKey: "onChannel") as? String
            else {
                completion(nil,"Error")
                return nil
        }
        content = recordContent
        senderID = recordSenderID
        senderDisplayName = recordSenderDisplayName
        sentDate = recordDate
        onChannel = recordChannel
        id = record.recordID.recordName
        kind = .text(content)
        sender = Sender(id: senderID, displayName: senderDisplayName)
        completion(self, nil)
    }
    
    var asCKRecord:CKRecord {
        let record = CKRecord(recordType: "Thread")
        record.setObject(self.content as __CKRecordObjCValue, forKey: "content")
        record.setObject(self.sentDate as __CKRecordObjCValue, forKey: "sentDate")
        record.setObject(self.onChannel as __CKRecordObjCValue, forKey: "onChannel")
        record.setObject(self.senderID as __CKRecordObjCValue, forKey: "senderID")
        record.setObject(self.senderDisplayName as __CKRecordObjCValue, forKey: "senderDisplayName")
        return record
    }
    
}

