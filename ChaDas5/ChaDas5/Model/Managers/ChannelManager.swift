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
    func readedChannels(channels: [Channel])
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
        let record = CKRecord(recordType: "Channel")
        record.setObject(story.id as __CKRecordObjCValue?, forKey: "fromStory")
        record.setObject(MeUser.instance.email as __CKRecordObjCValue?, forKey: "creator")
        record.setObject(story.date as __CKRecordObjCValue?, forKey: "lastMessageDate")
        
        print("===========", record.recordID)
        
        self.database.save(record, completionHandler: {(record, error) in
            if let error = error {
                completion(nil, error)
            }
            if let record = record {
                completion(record, nil)
            }
        })
    }
    
    func getBlockedList(requester: ChannelManagerProtocol) {
        self.block = []
        // TODO: Get list of blocked users
    }

    
    func getChannels(requester: ChannelManagerProtocol) {
        // TODO: Get list of channels
        loadUsernames(requester: requester)
    }
    
    
    func loadUsernames(requester: ChannelManagerProtocol) {
        /// from (https://stackoverflow.com/questions/35906568/wait-until-swift-for-loop-with-asynchronous-network-requests-finishes-executing)
//        let dispatch = DispatchGroup()
//        
//        for channel in self.channels {
//            dispatch.enter()
//            guard let first = channel.firstUser?.uid else { return }
//            guard let second = channel.secondUser?.uid else { return }
//            
//            self.retriveDisplayName(withUID: first) { (fUsername, error) in
//                if let error = error {
//                    debugPrint("Error retrieving first display name", error.localizedDescription)
//                }
//                channel.firstUser?.displayName = fUsername
//                self.retriveDisplayName(withUID: second) { (sUsername, error) in
//                    if let error = error {
//                        debugPrint("Error retrieving second display name", error.localizedDescription)
//                    }
//                    channel.secondUser?.displayName = sUsername
//                    dispatch.leave()
//                }
//            }
//        }
//        dispatch.notify(queue: .main) {
//            requester.readedChannels(channels: self.channels)
//        }
    }
    
    func retriveDisplayName(withUID uid: String, completion: @escaping (String?, Error?) -> Void) {
        // TODO: Get username from userID
        
        // FIXME: Completion
        completion(nil, nil)
    }
    
    func deleteChannel(channelID: String) {
        
    }
    
}
