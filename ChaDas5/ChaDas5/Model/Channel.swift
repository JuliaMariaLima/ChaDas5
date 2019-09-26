//
//  Channel.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 29/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//


import UserNotifications
import CloudKit
import MessageKit

struct ChannelUser {
    var uid: String
    var displayName: String?
}

class Channel {
  
    var ownerID: String
    var fromStory: String
    var lastMessageDate: String
  
    init(fromStory: Story, lastMessageDate: Date = Date.distantPast) {
        self.ownerID = MeUser.instance.email
        self.fromStory = fromStory.date + fromStory.author
        self.lastMessageDate = lastMessageDate.keyString
    }
    
    init?(from record:CKRecord) {
        guard let recordOwner = record.object(forKey: "owner") as? String,
              let recordFromStory  = record.object(forKey: "fromStory") as? String,
              let recordLastMessageDate    = record.object(forKey: "lastMessageDate") as? String
        else {
            return nil
        }
        ownerID = recordOwner
        fromStory = recordFromStory
        lastMessageDate = recordLastMessageDate
    }
    
    var asCKRecord:CKRecord {
        let record = CKRecord(recordType: "Channel")
        record.setObject(self.fromStory as __CKRecordObjCValue?, forKey: "fromStory")
        record.setObject(MeUser.instance.email as __CKRecordObjCValue?, forKey: "owner")
        record.setObject(self.lastMessageDate as __CKRecordObjCValue?, forKey: "lastMessageDate")
        return record
    }

  }
