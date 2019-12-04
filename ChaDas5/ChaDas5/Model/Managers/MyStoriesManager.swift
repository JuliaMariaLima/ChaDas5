//
//  DAO.swift
//  ChaDas5
//
//  Created by Gabriela Szpilman on 11/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit

class MyStoriesManager {
    
    var database: CKDatabase
    var container: CKContainer
    
    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
    }

    var nonActiveStories = [CKRecord]()
    var activeStories = [CKRecord]()
    
    func loadMyStories(requester:StoryManagerProtocol) {
        var activeStories: [CKRecord] = []
        var nonActiveStories: [CKRecord] = []
        let predicate = NSPredicate(format: "author = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "Story", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                print(error!)
                requester.readedMyStories(stories: [[]])
                return
            }
            for result in results ?? [] {
                guard let status = result["status"] as? String else { return }
                if status == "active" {
                    activeStories.append(result)
                } else {
                    nonActiveStories.append(result)
                }
            }
            activeStories.sort(by: { $0.creationDate! > $1.creationDate! })
            nonActiveStories.sort(by: { $0.creationDate! > $1.creationDate! })
            self.activeStories = activeStories
            self.nonActiveStories = nonActiveStories
            requester.readedMyStories(stories: [results!, []])
            return
        })
        requester.readedMyStories(stories: [[]])
    }
    
    
    func switchToNonAvaliable(storyID: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Story", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            // Erro ao executar query no CloudKit.
            if error != nil {
                print("erro no cloudkit")
                completion(nil, nil)
                return
            }
            if (results?.count)! > 0 {
                for result in results! {
                    let nonAvaliable = "non_avaliable"
                    if result.recordID.recordName == storyID {
                        result.setObject(nonAvaliable as CKRecordValue?, forKey: "isEnabled")
                        self.database.save(result, completionHandler: {(record,error) -> Void in
                            if let error = error {
                                print(#function, error)
                                completion(nil, error)
                                return
                            }
                            print("sucesso no upload")
                            completion(record, nil)
                            return
                        })
                    }
                }
            }
            completion(nil, nil)
        })
    }

    
    func switchArchived(storyID: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(format: "author = %@", MeUser.instance.email)
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
                        guard let status = result["status"] as? String else {
                            print("saiu aqui")
                            return }
                        if status == "archived" {
                            result.setObject("active" as __CKRecordObjCValue, forKey: "status")
                        } else if status == "active" {
                            result.setObject("archived" as __CKRecordObjCValue, forKey: "status")
                        }
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
    
    func retrieve(statusFrom story: CKRecord, completion: @escaping (String?, String?) -> Void) {
        guard let status = story["status" ] as? String else {
            completion(nil, "Error")
            return
        }
        completion(status, nil)
    }
    
    func retrieve(avaliablilityFrom story: CKRecord, completion: @escaping (String?, String?) -> Void) {
        guard let status = story["isEnabled" ] as? String else {
            completion(nil, "Error")
            return
        }
        completion(status, nil)
    }
    
}


// - TODO: Reload data when find a new record
