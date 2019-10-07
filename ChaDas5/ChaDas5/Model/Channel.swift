//
//  Channel.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 29/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//


import UserNotifications
import CloudKit

struct ChannelUser {
    var uid: String
    var displayName: String?
}

class Channel {
  
    var id: String?
    var ownerID: String
    var fromStory: String
    var lastMessageDate: String
  
    init(fromStory: Story, lastMessageDate: Date = Date.distantPast) {
        self.ownerID = MeUser.instance.email
        self.fromStory = fromStory.date + "|" + fromStory.author
        self.lastMessageDate = lastMessageDate.keyString
        self.id = nil
    }
    
    init?(from record:CKRecord, completion: @escaping (Channel?, String?) -> Void)  {
        guard let recordOwner = record["owner"] as? String,
              let recordFromStory  = record["fromStory"] as? String,
              let recordLastMessageDate    = record["lastMessageDate"] as? String
        else {
            completion(nil, NSError().description)
            return nil
        }
        ownerID = recordOwner
        fromStory = recordFromStory
        lastMessageDate = recordLastMessageDate
        id = record.recordID.recordName
        completion(self, nil)
    }
    
    var asCKRecord:CKRecord {
        let record = CKRecord(recordType: "Channel")
        record.setObject(self.fromStory as __CKRecordObjCValue?, forKey: "fromStory")
        record.setObject(self.ownerID as __CKRecordObjCValue?, forKey: "owner")
        record.setObject(self.lastMessageDate as __CKRecordObjCValue?, forKey: "lastMessageDate")
        return record
    }

  }
