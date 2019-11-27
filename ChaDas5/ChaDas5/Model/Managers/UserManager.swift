//
//  DAOUsers.swift
//  MeAcompanha
//
//  Created by Julia Maria Santos on 03/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//

import CloudKit
import UIKit

protocol UserRequester {
    func saved(userRecord: CKRecord?, userError: Error?)
    func retrieved(user: User?, userError: Error?)
    func retrieved(userArray: [User]?, userError: Error?)
    func retrieved(meUser: MeUser?, meUserError: Error?)
    func retrieved(user: User?, fromIndex: Int, userError: Error?)
}


class UserManager {
    var database: CKDatabase
    var container: CKContainer
    
    let teas = ["Gengibre", "Frutas Vermelhas", "Erva Doce", "Camomila", "Capim Limão", "Chá Preto", "Hibisco", "Hortelã"]
//    
//    var currentUser:String {
//        
//    }
    
    init(database: CKDatabase, container: CKContainer) {
        self.container = container
        self.database = database
    }
    
    func save(newUser: MeUser, requester: UserRequester) {
        let predicate = NSPredicate(format: "email = %@", newUser.email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            // Erro ao executar query no CloudKit.
            if error != nil{
                print("erro no cloudkit", error.debugDescription)
            } else {
                // Não há registro com o nome fornecido já salvo no CloudKit.
                if (results!.count == 0) {
                    let record = CKRecord(recordType: "User")
                    record.setObject(newUser.name as CKRecordValue?, forKey: "name")
                    record.setObject(newUser.email as CKRecordValue?, forKey: "email")
                    record.setObject(newUser.genderId as CKRecordValue?, forKey: "gender")
                    record.setObject(newUser.password as CKRecordValue?, forKey: "password")
                    record.setObject(newUser.blocked as CKRecordValue?, forKey: "blocked")
                    record.setObject(newUser.birthDate as CKRecordValue?, forKey: "birthDate")
                    
                    
                    // Salvar nome do CloudKit.
                    self.database.save(record, completionHandler: {(record,error) -> Void in
                        
                        if (error != nil) {
                            print(#function, error!)
                            requester.saved(userRecord: nil, userError: error)
                            return
                        }
                        print("sucesso")
                        requester.saved(userRecord: record, userError: nil)
                        return
                    })
                } else { // Há registro com o nome fornecido já salvo no CloudKit.
                    print("ja tem esse email salvo")
                    requester.saved(userRecord: nil, userError: nil)
                }
            }
        })
    }
    
    func isSave(meUser: MeUser, completionHandler: @escaping ((Bool) -> Void)) {
        let predicate = NSPredicate(format: "email = %@", meUser.email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil, completionHandler: {(results, error) in
            if let _ = error {
                completionHandler(false)
                return
            }
            if let results = results, results.count > 0 {
                completionHandler(true)
                return
            }
            completionHandler(false)
        })
    }
    
    func get(meFromEmail: String, requester: UserRequester) {
        let predicate = NSPredicate(format: "email = %@", meFromEmail)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil, completionHandler: {(result, error) in
            if error != nil {
                print("erro no cloudkit \(#function)")
                requester.retrieved(meUser: nil, meUserError: error)
                return
            }
            if let result = result,
                result.count == 1 {
                // ja existe
                let record = result.first
                let meUser = self.get(meFromRecord: record!)
                requester.retrieved(meUser: meUser, meUserError: nil)
                return
            } else {
                // nao existe
                requester.retrieved(meUser: nil, meUserError: nil)
            }
        })
    }
    
    
    func get(meFromRecord: CKRecord) -> MeUser {
        guard let name = meFromRecord["name"] as? String,
              let email = meFromRecord["email"] as? String,
              let password = meFromRecord["password"] as? String,
              let genderId = meFromRecord["gender"] as? String,
              let birthDate = meFromRecord["birthDate"] as? String
//              let blocked = meFromRecord["blocked"] as? [String]
            else { fatalError() }
        let meUser = MeUser(name: name, email: email, password: password, genderId: genderId, birthDate: birthDate, blocked: [])
        return meUser
    }
    
    func get(userFromRecord: CKRecord) -> User {
        let name = userFromRecord["name"] as! String
        let email = userFromRecord["email"] as! String
        let user = User(name: name, email: email)
        return user
    }
    
    func edit(meUser: MeUser,requester: UserRequester) {
        let predicate = NSPredicate(format: "email = %@", meUser.email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            
            // Erro ao executar query no CloudKit.
            if let error = error {
                print("erro no cloudkit")
                requester.saved(userRecord: nil, userError: error)
                return
            }
            
            // Não há registro com o nome fornecido já salvo no CloudKit.
            guard let results = results, results.count > 0 else {
                print("nao tem esse email salvo")
                requester.saved(userRecord: nil, userError: nil)
                return
            }
            
            let record = results.first!
            
            record.setObject(meUser.name as CKRecordValue?, forKey: "name")
            record.setObject(meUser.email as CKRecordValue?, forKey: "email")
            record.setObject(meUser.password as CKRecordValue?, forKey: "password")
            // Salvar nome do CloudKit.
            self.database.save(record, completionHandler: {(record,error) -> Void in

                if let error = error {
                    print(#function, error)
                    requester.saved(userRecord: nil, userError: error)
                    return
                }
                print("sucesso no upload")
                requester.saved(userRecord: record, userError: nil)
                return
            })
        })
    }
    
    func block(_ user: String, requester: UserRequester) {
        let predicateMe = NSPredicate(format: "email = %@", MeUser.instance.email)
        let queryMe = CKQuery(recordType: "User", predicate: predicateMe)
        
        self.database.perform(queryMe, inZoneWith: nil) {(records, error) in
            if let error = error {
                requester.saved(userRecord: nil, userError: error)
                return
            }
            
            if let records = records,
                records.count == 1 {
                let record = records.first
                var blocked = record!["blocked"] as? [String] ?? []
                
                blocked.append(user)
                MeUser.instance.blocked.append(user)
                record?.setValue(blocked, forKeyPath: "blocked")
                self.database.save(record!, completionHandler: {(record, error) in
                    if let error = error {
                        requester.saved(userRecord: nil, userError: error)
                        return
                    }
                })
            }
        }
    }
    
    
    
    func blockAnother(_ user: String, requester: UserRequester) {
        let predicateMe = NSPredicate(format: "email = %@", user)
        let queryMe = CKQuery(recordType: "User", predicate: predicateMe)
        
        self.database.perform(queryMe, inZoneWith: nil) {(records, error) in
            if let error = error {
                requester.saved(userRecord: nil, userError: error)
                return
            }
            
            if let records = records,
                records.count == 1 {
                let record = records.first
                var blocked = record!["blocked"] as? [String] ?? []
                
                blocked.append(MeUser.instance.email)
                record?.setValue(blocked, forKeyPath: "blocked")
                self.database.save(record!, completionHandler: {(record, error) in
                    if let error = error {
                        requester.saved(userRecord: nil, userError: error)
                        return
                    }
                })
            }
        }
    }
    
    
    func get(blocksFrom me: MeUser, requester: UserRequester) {
        let predicate = NSPredicate(format: "email = %@", me.email)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil) {(records, error) in
            if let error = error {
                requester.retrieved(meUser: nil, meUserError: error)
                return
            }
            
            if let records = records,
                records.count == 1 {
                let record = records.first
                let blocked = record!["blocked"] as? [String] ?? []
                
                me.blocked = blocked
                requester.retrieved(meUser: me, meUserError: nil)
            }
        }
    }
    
    func retrieve(authorFrom story: String, completion: @escaping (String?, String?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Story", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil) {(records, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            if let records = records {
                for record in records {
                    if record.recordID.recordName == story {
                        guard let author = record["author"] as? String else {
                            completion(nil, nil)
                            return
                        }
                        completion(author, nil)
                    }
                }
            }
        }
    }
    
    func retrieve(authorFrom story: CKRecord, completion: @escaping (String?, String?) -> Void) {
        guard let author = story["author"] as? String else {
            completion(nil, "Error")
            return
        }
        completion(author, nil)
    }
    
    func retrieve(nameFrom user: String, completion: @escaping (String?, String?) -> Void) {
        let predicate = NSPredicate(format: "email = %@", user)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil) {(records, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            if let records = records,
            records.count == 1 {
                let record = records.first
                guard let username = record!["name"] as? String else {
                    completion(nil, nil)
                    return
                }
                completion(username, nil)
            }
        }
    }
    
    func retrieveDateOfEntry(from user: String, completion: @escaping (String?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        self.database.perform(query, inZoneWith: nil) {(records, error) in
            if error != nil {
                debugPrint(error!.localizedDescription)
                completion(nil)
                return
            }
            if let records = records {
                for record in records {
                    guard let author = record["email"] as? String else { return }
                    if author == user {
                        let date = record.creationDate?.keyString
                        completion(date)
                    }
                }
                completion(nil)
            }
        }
    }
    
}

