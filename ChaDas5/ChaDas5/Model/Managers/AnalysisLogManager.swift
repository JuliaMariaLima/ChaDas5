//
//  AnalysisLogManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 22/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML
import CloudKit

protocol AnalysisLogProtocol {
    
    func createdAnalysisLog()
    
    func retrievedAnalysisLog(with analysisLog: AnalysisLog)
    
    func updatedAnalysisLog()
    
    func createdAnalysisLog(with error: Error)
    
    func retrievedAnalysisLog(with error: Error)
    
    func updatedAnalysisLog(with error: Error)
    
}

class AnalysisLogManager {
    
    var database: CKDatabase
    var container: CKContainer
    
    let classifier:NLModel?

    
    init(database: CKDatabase, container: CKContainer){
        self.container = container
        self.database = database
        
        self.classifier = try? NLModel(mlModel: emotions().model)
    }
    
    func checkAnalysisLog(completion: @escaping (Bool?) -> Void) {
        let predicate = NSPredicate(format: "user = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "AnalysisLog", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                debugPrint(error!.localizedDescription)
                return
            }
            if (results?.count)! > 0 {
                completion(true)
                return
            }
            completion(false)
        })
    }

    func setUpAnalysisLog(with manager: AnalysisLogProtocol) {
        let analysis = AnalysisLog()
        DAOManager.instance?.ckUsers.retrieveDateOfEntry(from: MeUser.instance.email, completion: { (date) in
            if date != nil {
                analysis.dateOfEntry = date!
                self.save(analysis: analysis, with: manager)
            }
        })

    }
    
    func save(analysis: AnalysisLog, with manager: AnalysisLogProtocol) {
        self.database.save(analysis.asCKRecord) { (record, error) in
            if error != nil {
                debugPrint(error!.localizedDescription)
                manager.createdAnalysisLog(with: error!)
            } else if record != nil {
                debugPrint("saved")
                manager.createdAnalysisLog()
            }
        }
    }
    
    func retrieveAnalysisLog(with manager: AnalysisLogProtocol) {
        let predicate = NSPredicate(format: "user = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "AnalysisLog", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                debugPrint(error!.localizedDescription)
                manager.retrievedAnalysisLog(with: error!)
                return
            }
            if (results?.count)! > 0 {
                _ = AnalysisLog(from: (results?.first)!) { (analysis) in
                    if analysis == nil {
                        // error handling
                    } else {
                        manager.retrievedAnalysisLog(with: analysis!)
                    }
                }
            }
        })
    }
    
    func getLog(completion: @escaping (CKRecord?) -> Void) {
        let predicate = NSPredicate(format: "user = %@", MeUser.instance.email)
        let query = CKQuery(recordType: "AnalysisLog", predicate: predicate)
        self.database.perform(query, inZoneWith: nil, completionHandler: { (results, error) in
            if error != nil {
                debugPrint(error!.localizedDescription)
                return
            }
            if (results?.count)! > 0 {
                    completion(results?.first)
            }
        })
    }
    
    
    func updateStatus(new status: Status, on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool) {
        log.setObject(status.rawValue as __CKRecordObjCValue, forKey: "status")
        if hasCompletion {
            updateAnalysisLog(on: log, with: manager)
        }
    }
    
    func updateEmpathyResult(new result: Double, on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool) {
        log.setObject(result as __CKRecordObjCValue, forKey: "empathyResult")
        updateAnalysisLog(on: log, with: manager)
    }
    
    func updateInputs(on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool) {
        var inputs = 1
        if let input = log["inputs"] as? Int {
            inputs += input
        }
        log.setObject(inputs as __CKRecordObjCValue, forKey: "inputs")
        if hasCompletion {
            updateAnalysisLog(on: log, with: manager)
        }
    }
    
    func updateDateOfLastInput(new date: String, on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool ) {
        log.setObject(date as __CKRecordObjCValue, forKey: "dateOfLastInteraction")
        if hasCompletion {
            updateAnalysisLog(on: log, with: manager)
        }
        
    }
    
    func updateEmpathyAnswers(new answers: [Int], on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool ) {
        // check if empty
        guard let currentAnswers = log["empathyAnswers"] as? [Int] else {
            return
            
        }
        if currentAnswers.count >= 22 {
            debugPrint("more answers already logged than expected")
        }
        let newAnswers = currentAnswers + answers
        if newAnswers.count >= 22 {
            debugPrint("more answers than expected")
        }
        log.setObject(newAnswers as __CKRecordObjCValue, forKey: "empathyAnswers")
        if hasCompletion {
            updateAnalysisLog(on: log, with: manager)
        }
    }
   
    func updateQuestionableInputs(new questionableInput: String, on log:CKRecord, with manager: AnalysisLogProtocol, hasCompletion: Bool ) {
        guard let questinableInputs = log["questionableInputs"] as? [String] else {
            debugPrint("error getting questionable inputs")
            return
        }
        var newInputs = questinableInputs
        newInputs.append(questionableInput)
        log.setObject(newInputs as __CKRecordObjCValue, forKey: "questionableInputs")
        if hasCompletion {
            updateAnalysisLog(on: log, with: manager)
        }
    }
    
    func updateAnalysisLog(on log:CKRecord, with manager: AnalysisLogProtocol) {
        self.database.save(log) { (record, error) in
            if error == nil && record != nil {
                manager.updatedAnalysisLog()
            } else if error != nil {
                manager.updatedAnalysisLog(with: error!)
            }
        }
    }
    
    func classifyInput(with input:String, on date:String, with manager: AnalysisLogProtocol) {
        let questionable = ["hate", "anger"]
        let classification = self.classifier?.predictedLabel(for: input)
        let stringLog = input + " - " + classification!
        getLog { (record) in
            if record != nil {
                self.updateInputs(on: record!, with: manager, hasCompletion: false)
                self.updateDateOfLastInput(new: date, on: record!, with: manager, hasCompletion: true)
                if questionable.contains(classification!) {
                    self.updateQuestionableInputs(new: stringLog, on: record!, with: manager, hasCompletion: true)
                }
            }
        }
    }
    
    
    func calculateEmpathy(on log: CKRecord, with manager: AnalysisLogProtocol) {
        guard let answers = log["empathyAnswers"] as? [Int] else { return }
        // fix order
        let invertAnswersFor = [3, 4, 5, 7, 11, 22]
        var sum = 0.0
        for i in answers {
            if invertAnswersFor.contains(i+1) {
                sum = sum + invert(value: answers[i])
            } else {
                sum = sum + Double(answers[i])
            }
        }
        self.updateEmpathyResult(new: sum/22, on: log, with: manager, hasCompletion: true)
        
    }
    
    func invert(value:Int) -> Double {
        let invert = [4, 3, 2, 1]
        return Double(invert[value - 1])
    }
    
    
}
