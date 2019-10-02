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
    var stories = [CKRecord]()

    
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
    
    func retrieve(authorFrom storyID: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(format: "email = %@", "")
        let query = CKQuery(recordType: "User", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            if error != nil {
                print("erro no cloudkit \(#function)", error.debugDescription)
                completion(nil, error)
                return
            }
            if (results?.count)! > 0 {
            
            for result in results! {
                if result.recordID.recordName == storyID {
                    completion(result, nil)
                }
            }
            }
            else {
                // nao existe
                completion(nil, nil)
            }
        })
    }
    
    func retrieve(contentFrom story: CKRecord, completion: @escaping ([String:String]?, Error?) -> Void) {
        guard let content = story["content"] as? String,
              let author = story["author"] as? String else {
                completion(nil, NSError())
                return
        }
        completion(["author":author, "content":content], nil)
    }
    
}
