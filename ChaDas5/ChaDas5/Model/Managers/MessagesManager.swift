//
//  MessagesManager.swift
//  ChaDas5
//
//  Created by Julia Rocha on 10/01/19.
//  Copyright © 2019 Julia Maria Santos. All rights reserved.
//

import Foundation
import CloudKit


protocol MessagesProtocol {
    
    func readedMessagesFromChannel(messages:[Message])
}

class MessagesManager {
    
    static let instance = MessagesManager()
    private init(){}
    
    var messages = [Message]()
    
    func loadMessages(from channel: Channel, requester: MessagesProtocol) {
        // TODO: Get messages from channel

        requester.readedMessagesFromChannel(messages: self.messages)
        
    }
    
    
    

    
}
