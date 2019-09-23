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
    
    
    var kind: MessageKind
    let id: String?
    let content: String
    let sentDate: Date
    let sender: SenderType
    let onChannel: String
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    init(content: String, on channel: String) {
        let userID = MeUser.instance.email
        self.sender = Sender(id: userID, displayName: AppSettings.displayName)
        self.content = content
        sentDate = Date()
        id = nil
        kind = .text(content)
        onChannel = channel
    }
    
    
}
//
//extension Message {
//
//    var representation: [String : Any] {
//        let rep: [String : Any] = [
//            "created": sentDate,
//            "senderID": sender.senderId,
//            "senderName": sender.displayName,
//            "content":content
//        ]
//        return rep
//    }
//
//}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}

