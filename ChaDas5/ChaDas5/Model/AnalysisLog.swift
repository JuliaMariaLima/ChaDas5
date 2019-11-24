//
//  AnalysisLog.swift
//  ChaDas5
//
//  Created by Julia Rocha on 22/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit


class AnalysisLog {
    
    var user: String
    var status:Status
    var empathyResult: Double
    var inputs: Int
    var dateOfEntry: String
    var dateOfLastInteraction: String
    var empathyAnswers: [Int]
    var questionableInputs: [String]
    
    init() {
        self.user = MeUser.instance.email
        self.status = .inAnalysis
        self.empathyResult = 0.0
        self.empathyAnswers = []
        self.inputs = 0
        self.dateOfEntry = ""
        self.dateOfLastInteraction = ""
        self.questionableInputs = []
    }
    
    init?(from record:CKRecord, completion: @escaping (AnalysisLog?) -> Void) {
        guard let recordStatus = record["status"] as? String,
              let recordEmpathyResult   = record["empathyResult"] as? Double,
              let recordInputs   = record["inputs"] as? Int,
              let recordDateOfEntry     = record["dateOfEntry"] as? String,
              let recordDateOfLastInput = record["dateOfLastInteraction"] as? String,
              let recordEmpathyAnswers = record["empathyAnswers"] as? [Int],
              let recordQuestionableInputs    = record["questionableInputs"] as? [String]
        else {
            completion(nil)
            return nil
        }
        self.user = MeUser.instance.email
        self.status = .inAnalysis
        self.empathyResult = recordEmpathyResult
        self.dateOfEntry = recordDateOfEntry
        self.dateOfLastInteraction = recordDateOfLastInput
        self.empathyAnswers = recordEmpathyAnswers
        self.questionableInputs = recordQuestionableInputs
        self.inputs = recordInputs
        self.status = fromString(with: recordStatus)
        completion(self)
    }
    
    
    var asCKRecord:CKRecord {
        let record = CKRecord(recordType: "AnalysisLog")
        record.setObject(self.user as __CKRecordObjCValue, forKey: "user")
        record.setObject(self.status.rawValue as __CKRecordObjCValue, forKey: "status")
        record.setObject(self.dateOfEntry as __CKRecordObjCValue, forKey: "dateOfEntry")
        record.setObject(self.dateOfEntry as __CKRecordObjCValue, forKey: "dateOfEntry")
        record.setObject(self.dateOfLastInteraction as __CKRecordObjCValue, forKey: "dateOfLastInteraction")
        record.setObject(self.empathyAnswers as __CKRecordObjCValue, forKey: "empathyAnswers")
        record.setObject(self.questionableInputs as __CKRecordObjCValue, forKey: "questionableInputs")
        return record
    }
}


extension AnalysisLog {
    
    func fromString(with value:String) -> Status {
        switch value {
        case "finishedEmpathyTest":
            return .finishedEmpathyTest
        case "questionableInputs":
            return .questionableInputs
        case "empathic":
            return .empathic
        case "notSoEmpathic":
            return .notEmpathic
        case "notEmpathic":
            return .notEmpathic
        default:
            return .inAnalysis
        }
    }
}

