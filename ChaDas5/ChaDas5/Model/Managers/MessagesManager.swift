//
//  MessagesManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 10/01/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit


protocol MessagesProtocol {
    
    func readedMessagesFromChannel(messages:[Message]?, error:Error?)
    func messageSaved(with:Error)
    func messageSaved()
}

class MessagesManager {
    
    
    var database: CKDatabase
    var container: CKContainer
    
    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
    }
    
    var messages = [Message]()
    
    func loadMessages(from channel: Channel, requester: MessagesProtocol) {
        let predicate = NSPredicate(format: "onChannel = %@", channel.id ?? "")
        let query = CKQuery(recordType: "Thread", predicate: predicate)
        self.messages = []
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.readedMessagesFromChannel(messages: nil, error: nil)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    _ = Message(from: result) { (message, error) in
                        if error == nil && message != nil {
                            self.messages.append(message!)
                        }
                    }
                }
                self.messages = self.messages.sorted(by: { $0.sentDate < $1.sentDate })
                requester.readedMessagesFromChannel(messages: self.messages, error: nil)
                return
            }
            requester.readedMessagesFromChannel(messages: nil, error: nil)
        })
    }
    
    func save(message:Message, to requester: MessagesProtocol) {
        self.messages.append(message)
//        self.messages = self.messages.sorted(by: { $0.sentDate.keyString < $1.sentDate.keyString })

        self.database.save(message.asCKRecord, completionHandler: {(record, error) in
            if let error = error {
                debugPrint("==========", error)
                requester.messageSaved(with: error)
                return
            }
            if let _ = record {
                requester.messageSaved()
                return
            }
        })
    }
    

//    func save(message:Message, completion: @escaping (CKRecord?, Error?) -> Void) {
//        self.database.save(message.asCKRecord, completionHandler: {(record, error) in
//            if let error = error {
//                debugPrint("==========", error)
//                completion(nil, error)
//            }
//            if let record = record {
//
//                self.messages.append(message)
//                self.messages = self.messages.sorted(by: { $0.sentDate.keyString < $1.sentDate.keyString })
//                completion(record, nil)
//            }
//        })
//    }
    

}
