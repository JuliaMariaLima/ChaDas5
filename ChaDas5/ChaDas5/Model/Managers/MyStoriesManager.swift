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

    var nonActiveStories = [Story]()
    var activeStories = [Story]()
    
    func loadMyStories(requester:StoryManagerProtocol) {
        emptyArrays()
        
//        
//        requester.readedMyStories(stories: [self.nonActiveStories, self.activeStories])
    }
    
    func emptyArrays() {
        self.activeStories = []
        self.nonActiveStories = []
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
                    let nonAvaliable = false
                    if result.recordID.recordName == storyID {
                        result.setObject(nonAvaliable as CKRecordValue?, forKey: "status")
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
                    guard let toSwitch = result["status"] as? Bool else {
                        return
                    }
                    if result.recordID.recordName == storyID {
                        result.setObject(!toSwitch as CKRecordValue?, forKey: "isEnabled")
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
    
    
}

