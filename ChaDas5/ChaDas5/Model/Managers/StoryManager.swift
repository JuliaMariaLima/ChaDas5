//
//  RelatoManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 19/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit

protocol StoryManagerProtocol {
    
    func readedStories(stories:[CKRecord]?, error:Error?)
    
    func readedMyStories(stories:[[CKRecord]])
    
    func saved(reportRecord: CKRecord?, reportError: Error?)
    
}

class StoryManager {
    
    var database: CKDatabase
    var container: CKContainer

    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
    }
    
    func save(story:Story, completion: @escaping (CKRecord?, Error?) -> Void) {
        let record = CKRecord(recordType: "Story")
        record.setObject(story.content as __CKRecordObjCValue?, forKey: "content")
        record.setObject(story.author as __CKRecordObjCValue?, forKey: "author")
        record.setObject(story.date as __CKRecordObjCValue?, forKey: "date")
        record.setObject(story.status as __CKRecordObjCValue?, forKey: "status")
        
        print("===========", record.recordID)
        
        self.database.save(record, completionHandler: {(record, error) in
            if let error = error {
                completion(nil, error)
            }
            if let record = record {
                completion(record, nil)
                self.stories.append(record)
            }
        })
    }
    
    var stories = [CKRecord]()
    var block = [String]()
    
    func getBlockedList(requester: StoryManagerProtocol) {
        self.block = []
        // TODO: Get list of blocked users
        
        getStories(requester: requester, blocks: self.block)
    }
    
    func getStories(requester:StoryManagerProtocol, blocks:[String]) {
        self.stories = []
        // TODO: Get list of stories from database and cross with blocked list
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Story", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.readedStories(stories: nil, error: error)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    self.stories.append(result)
                }
                requester.readedStories(stories: results, error: nil)
                return
            }
            requester.readedStories(stories: nil, error: nil)
        })
    }
    
}
