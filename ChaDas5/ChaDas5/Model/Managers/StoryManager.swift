//
//  RelatoManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 19/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML
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
        self.database.save(story.asCKRecord, completionHandler: {(record, error) in
            if let error = error {
                completion(nil, error)
            }
            if let record = record {
                completion(record, nil)
                self.stories.append(record)
            }
        })
    }

    func preLoadStories(requester:StoryManagerProtocol) {
        self.stories = []
        // TODO: - Get list of stories from database and cross with blocked list
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
                    if result["status"] as? String == "active" {
                        self.stories.append(result)
                    }
                }
                requester.readedStories(stories: results, error: nil)
                return
            }
            requester.readedStories(stories: nil, error: nil)
        })
    }


    func switchToFlag (storyID: String, completion: @escaping (CKRecord?, Error?) -> Void) {

            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "Story", predicate: predicate)
            self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
                // Erro ao executar query no CloudKit.
                if error != nil {
                    print("erro no cloudkit")
                    completion(nil, nil)
                    return
                }
                if results != nil && (results?.count)! > 0 {
                    for result in results! {
                        if result.recordID.recordName == storyID {
                            guard let flag = result["flag"] as? Int else {
                                print("saiu aqui")
                                return }

                            result.setObject(flag+1 as __CKRecordObjCValue, forKey: "flag")

                            self.database.save(result) { (record, error) in
                                if error == nil && record != nil {
                                    completion(record, nil)
                                } else {
                                    completion(nil, error)
                                }
                            }
                        }
                    }
                }
            })
    }

    func getStories(requester:StoryManagerProtocol, blocks:[String]) {
        var stories:[CKRecord] = []
        let predicate = NSPredicate(format: "status = %@", "active")
        let query = CKQuery(recordType: "Story", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.readedStories(stories: nil, error: error)
                return
            }
            if (results?.count)! > 0 {

                for result in results! {
                    DAOManager.instance?.ckUsers.retrieve(authorFrom: result) { (author, error) in
                        if author != nil {
                            if !MeUser.instance.blocked.contains(author!) && result["status"] == "active" {
//                                guard let content = result["content"] as? String else { return }
//                                print(self.classifier?.predictedLabel(for: content), content)
                                self.stories.append(result)
                            if !MeUser.instance.blocked.contains(author!) {
                                stories.append(result)
                            }
                        }
                    }

                }
                stories.sort(by: { $0.creationDate! > $1.creationDate! })
                self.stories = stories
                requester.readedStories(stories: self.stories, error: nil)
                return
            }
            requester.readedStories(stories: nil, error: nil)
        })
    }


    func get(storyFrom id:String, completion: @escaping (CKRecord?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Story", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            if error != nil {
                print("erro no cloudkit \(#function)", error.debugDescription)
                completion(nil)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    if result.recordID.recordName == id {
                        completion(result)
                    }
                }
            }
            else {
                // nao existe
                completion(nil)
            }
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

    func retrieve(contentFrom story: CKRecord, completion: @escaping ([String:String]?, String?) -> Void) {
        guard let content = story["content"] as? String,
              let author = story["author"] as? String else {
                completion(nil, "Error")
                return
        }
        completion(["author":author, "content":content], nil)
    }

}
