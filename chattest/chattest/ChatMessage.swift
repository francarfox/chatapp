//
//  ChatMessage.swift
//  chattest
//
//  Created by Guest User on 5/29/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit

private let baseUrl = "https://lorempixel.com"

class ChatMessage: NSObject {

    var type: MessageType
    var text: String?
    var imageSize: CGSize?
    var imageUrl: String?
    var date: Date
    
    
    init(type: MessageType, text: String?, imageSize: CGSize? = nil) {
        self.type = type
        self.text = text
        self.imageSize = imageSize
        
        if let size = imageSize {
            imageUrl = "\(baseUrl)/\(Int(size.width))/\(Int(size.height))"
        }
        
        date = Date()
    }
    
}

enum MessageType {
    case text
    case image
}
