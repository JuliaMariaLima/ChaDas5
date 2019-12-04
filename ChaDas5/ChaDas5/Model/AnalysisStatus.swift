//
//  AnalysisStatus.swift
//  ChaDas5
//
//  Created by Julia Rocha on 22/11/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation


enum Status: String {
    
    case inAnalysis = "in analysis"
    case finishedEmpathyTest = "finished empathy test"
    case questionableInputs = "high level of questionable inputs"
    case empathic = "high score on empathy test and few questionable inputs"
    case notSoEmpathic = "low score on empathy test but few questionable inputs"
    case notEmpathic = "low score on empathy test and high level of questionable inputs"
}
