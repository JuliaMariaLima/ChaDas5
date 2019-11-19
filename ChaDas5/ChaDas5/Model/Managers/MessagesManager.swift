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
    func deleted()
    func deletedError(with:Error)
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
        guard let id = channel.id?.recordName else { return }
        let predicate = NSPredicate(format: "onChannel = %@", id)
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
                DAOManager.instance?.ckChannels.updateOpenedBy(with: Date.distantFuture, on: id)
                requester.readedMessagesFromChannel(messages: self.messages, error: nil)
                return
            }
            requester.readedMessagesFromChannel(messages: nil, error: nil)
        })
    }
    
    // FIX 
    func save(message:Message, to requester: MessagesProtocol) {
        self.messages.append(message)
//        self.messages = self.messages.sorted(by: { $0.sentDate.keyString < $1.sentDate.keyString })

        self.database.save(message.asCKRecord, completionHandler: {(record, error) in
            if let error = error {
                debugPrint("==========", error)
                requester.messageSaved(with: error)
                return
            }
            // CHECK
            if let _ = record {
                let _ = Message(from: record!) { (message, error) in
                    if error == nil && message != nil {
                        DAOManager.instance?.ckChannels.updateLastMessageDate(with: message!, on: message!.onChannel)
                        requester.messageSaved()
                    }
                }
                return
            }
        })
    }
    
    func deleteAllFromChannel(from channel:String, requester: MessagesProtocol) {
        let predicate = NSPredicate(format: "onChannel = %@", channel)
        let query = CKQuery(recordType: "Thread", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.deletedError(with: error!)
                return
            }
            if results != nil && (results?.count)! > 0 {
                for result in results! {
                    self.database.delete(withRecordID: result.recordID) { (id, error) in
                        if error != nil {
                            requester.deletedError(with: error!)
                        }
                    }
                }
                requester.deleted()
            }
        })
    }
    
    
    func getMessageData(on messageID: String, completion: @escaping (Message?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Thread", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if results != nil && (results?.count)! > 0 {
                for result in results! {
                    if result.recordID.recordName == messageID {
                        _ = Message(from: result) { (message, error) in
                            if message != nil && error == nil {
                                completion(message)
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    
    // WARNING: THIS FUNCTION DELETED ALL MESSAGES FROM DATABASE
    func deleteAll() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Thread", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if results != nil && (results?.count)! > 0 {
                for result in results! {
                    self.database.delete(withRecordID: result.recordID) { (id, error) in
                        if error != nil {
                            print(error.debugDescription)
                        }
                    }
                }
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
