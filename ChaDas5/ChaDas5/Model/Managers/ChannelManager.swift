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


    func createChannel(withStory story: Story, completion: @escaping (CKRecord?, Error?) -> Void) {
        let record = Channel(fromStory: story).asCKRecord
        self.database.save(record, completionHandler: {(record, error) in
            if let error = error {
                completion(nil, error)
            }
            if let record = record {
                completion(record, nil)
            }
        })
    }
    
    func getChannels(requester: ChannelManagerProtocol) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Channel", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.readedChannels(channels: nil, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    guard let channel = Channel(from: result) else {
                        return
                    }
                    var storyAuthor = ""
                    DAOManager.instance?.ckStories.retrieve(authorFrom: channel.fromStory, completion: { (record, error) in
                        storyAuthor = record?["author"] ?? ""
                    })
                    if channel.ownerID == MeUser.instance.email || storyAuthor == MeUser.instance.email {
                        self.channels.append(channel)
                    }
                }
                requester.readedChannels(channels: self.channels, error: nil)
                return
            }
            requester.readedChannels(channels: nil, error: nil)
        })
    }
    
    func deleteChannel(channelID: String) {
        
    }
    
}
