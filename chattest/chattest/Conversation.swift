//
//  Conversation.swift
//  chattest
//
//  Created by Technorides on 5/30/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit

class Conversation: NSObject {
    var id: String
    private(set) var messages: [ChatMessage] //readonly
    
    init(id: String) {
        self.id = id
        messages = [ChatMessage]()
    }
    
    func addMessage(_ newMessage: ChatMessage) {
        messages.append(newMessage)
    }
    
    func addMessagesToFront(_ newMessages: [ChatMessage]) {
        messages.insert(contentsOf: newMessages, at: 0)
    }
    
    func addMessageToFront(_ newMessage: ChatMessage) {
        messages.insert(newMessage, at: 0)
    }
    
}
