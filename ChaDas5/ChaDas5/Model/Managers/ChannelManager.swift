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
    func readedChannels(channels: [Channel]?, error: Error?)
}

class ChannelManager {
    
    var database: CKDatabase
    var container: CKContainer
    
    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
    }
    
    var channels = [Channel]()
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
        self.channels = []
        let predicate = NSPredicate(format: "owner = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                requester.readedChannels(channels: nil, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    _ = Channel(from: result) { (channel, error) in
                        if error == nil && channel != nil {
                            self.channels.append(channel!)
                        }
                    }
                }
            }
            let predicate = NSPredicate(format: "fromStory = %@", MeUser.instance.email)
            let query = CKQuery(recordType: "Channel", predicate: predicate)
            self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                requester.readedChannels(channels: self.channels, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    _ = Channel(from: result) { (channel, error) in
                        if error == nil && channel != nil {
                            self.channels.append(channel!)
                        }
                    }
                }
                self.channels = self.channels.sorted(by: { $0.lastMessageDate > $1.lastMessageDate })
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
            }
            completion(false)
        }
    }
    
    func updateLastMessageDate(with date:Date, on channel:String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error == nil && results != nil {
                for result in results! {
                    if result.recordID.recordName == channel {
                        result.setValue(date.keyString, forKey: "lastMessageDate")
                        print(result.description)
                        self.database.save(result) { (record, error) in
                            if error != nil {
                                debugPrint(error.debugDescription)
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    
}
