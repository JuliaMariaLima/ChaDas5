//
//  ChannelsManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 03/01/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit

protocol ChannelManagerProtocol {
    func readedChannels(channels: [CKRecord]?, error: Error?)
}

class ChannelManager {
    
    var database: CKDatabase
    var container: CKContainer
    
    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
    }
    
    var channels = [CKRecord]()
    var block = [String]()


    func createChannel(withChannel channel: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void) {
        self.database.save(channel, completionHandler: {(record, error) in
            if let error = error {
                completion(nil, error)
            }
            if let record = record {
                completion(record, nil)
            }
        })
    }
    
    func getChannels(requester: ChannelManagerProtocol) {
        var channels:[CKRecord] = []
        let predicate = NSPredicate(format: "owner = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                requester.readedChannels(channels: nil, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    channels.append(result)
                }
            }
            let predicate = NSPredicate(format: "storyAuthor = %@", MeUser.instance.email)
            let query = CKQuery(recordType: "Channel", predicate: predicate)
            self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if let error = error {
                
                self.channels = self.channels.sorted(by: { $0.modificationDate!.keyString > $1.modificationDate!.keyString })
                requester.readedChannels(channels: self.channels, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    channels.append(result)
                }
                channels.sort(by: { $0.modificationDate!.keyString > $1.modificationDate!.keyString })
                self.channels = channels
                requester.readedChannels(channels: self.channels, error: nil)
                return
            }
            requester.readedChannels(channels: nil, error: nil)
        })
        })
    }
    
    func deleteChannel(channelID: CKRecord.ID, completion: @escaping (Bool) -> Void) {
        self.database.delete(withRecordID: channelID) { (record, error) in
            if error == nil && record != nil {
                debugPrint("record deleted")
                DaoPushNotifications.instance.deleteSubscriptionRecord(from: channelID.recordName)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    func updateLastMessageDate(with message: Message, on channel:String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error == nil && results != nil {
                for result in results! {
                    if result.recordID.recordName == channel {
                        debugPrint("=======", message.messageId, message.sentDate)
                        result.setValue(message.messageId, forKey: "lastMessageID")
                        result.setValue(message.sentDate.keyString, forKey: "lastMessageDate")
                        self.database.save(result) { (record, error) in
                            if error != nil {
                                debugPrint(#function, error.debugDescription)
                            } else {
                                debugPrint("saved record")
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    func updateOpenedBy(with date:Date, on channel:String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error == nil && results != nil {
                for result in results! {
                    if result.recordID.recordName == channel {
                        guard let owner = result["owner"] as? String else { return }
                        if MeUser.instance.email == owner {
                            result.setValue(date.keyString, forKey: "lastOpenByOwner")
                            self.database.save(result) { (record, error) in
                                debugPrint("agora aqui")

                                if error != nil {
                                    debugPrint(#function, error.debugDescription)
                                } else {
                                    debugPrint("foi")
            //                        debugPrint("saved record")
                                }
                            }
                        } else {
                            result.setValue(date.keyString, forKey: "lastOpenByStoryAuthor")
                            self.database.save(result) { (record, error) in
                                debugPrint("agora aqui")

                                if error != nil {
                                    debugPrint(#function, error.debugDescription)
                                } else {
                                    debugPrint("foi")
            //                        debugPrint("saved record")
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    
}
