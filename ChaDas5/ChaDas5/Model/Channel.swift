//
//  Channel.swift
//  ChaDas5
//
//  Created by Nathalia Inacio on 29/12/18.
//  Copyright © 2018 Julia Maria Santos. All rights reserved.
//


import UserNotifications
import CloudKit
import MessageKit

struct ChannelUser {
    var uid: String
    var displayName: String?
}

class Channel {
  
    var id: String?
    var owner: ChannelUser?
    var fromStory: String?
    var lastMessageDate: Date?
  
    init(owner: User, fromStory: Story, lastMessageDate: Date = Date.distantPast) {
        self.id = owner.id + "|" + (fromStory.author ?? "no_author_from_story")
        self.owner = ChannelUser(uid: owner.id, displayName: owner.name)
        self.fromStory = fromStory.id
    }
  }
