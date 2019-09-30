//
//  DAOManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 03/09/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class DAOManager {
    
    static let instance = DAOManager()
    var database: CKDatabase
    var container: CKContainer
    var ckStories: StoryManager
    var ckUsers: UserManager
    var ckMessages: MessagesManager
    var ckChannels: ChannelManager
    var ckMyStories: MyStoriesManager
    
    // MARK:- Configure Cloud
    private init?() {
        container = CKContainer(identifier: "iCloud.appledeveloperacademy.ChadasCinco")
        database = container.publicCloudDatabase
        container.accountStatus{(status, error) -> Void in
            if status == .noAccount {
                DispatchQueue.main.sync {
                    print("Sem acesso ao iCloud")
                    let alert = UIAlertController(title: "", message: "Sem acesso ao iCloud. Por favor se conecte", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    alert.present(CreateNewAccount(), animated: true, completion: nil)
                    alert.present(Login(), animated: true, completion: nil)
                }
                return
            }
        }
        self.ckStories = StoryManager(database: database, container: container)
        self.ckUsers = UserManager(database: database, container: container)
        self.ckMessages = MessagesManager(database: database, container: container)
        self.ckChannels = ChannelManager(database: database, container: container)
        self.ckMyStories = MyStoriesManager(database: database, container: container)
    }
}
