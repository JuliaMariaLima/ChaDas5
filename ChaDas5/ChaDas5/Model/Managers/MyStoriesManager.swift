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
    
    static let instance = MyStoriesManager()
    private init(){}

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
    
    
    func switchToNonAvaliable(storyID: String) {
        
    }
    
    func switchToArchived(storyID: String) {
        
    }
    
    
}

