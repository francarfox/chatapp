//
//  ChatService.swift
//  chattest
//
//  Created by Guest User on 5/29/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit
import Alamofire

private let imageCache = NSCache<NSString, UIImage>()
private let conversationCache = NSCache<NSString, Conversation>()

class ChatService {
    static let shared = ChatService()
    
    private init() { }
    
    
    func loadImage(withUrl url: String, completion: @escaping (UIImage)->Void) {
        
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            completion(cachedImage)
            return
        }
        
        //request to service
        Alamofire.request(url).responseData { response in
            guard let data = response.result.value else { return }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url as NSString)
                    completion(image)
                }
            }
        }
        
    }
    
    func sendMessage(_ message: ChatMessage, conversationId: String, completion: ()->Void) {
        var conversation = Conversation(id: conversationId)
        
        if let cachedConversation = conversationCache.object(forKey: conversationId as NSString) {
            conversation = cachedConversation
        }
        
        conversation.addMessageToFront(message)
        conversationCache.setObject(conversation, forKey: conversationId as NSString)
        completion()
    }
    
    func fetchMesagesInCache(conversationId: String, count: Int, page: Int, completion: ([ChatMessage])->Void) {
        
        if let cachedConversation = conversationCache.object(forKey: conversationId as NSString) {
            let messages = cachedConversation.messages
            let startIndex = page * count
            let endIndex = messages.indices.contains(startIndex+count-1) ? startIndex+count-1 : messages.count-1
            
            if messages.indices.contains(startIndex) {
                let results = messages[startIndex ... endIndex]
                completion(Array(results))
            }
        }
        
    }
    
}
