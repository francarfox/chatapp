//
//  MessagesViewController.swift
//  chattest
//
//  Created by Technorides on 5/30/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit

private let chatMessageCellId = "ChatMessageCell"

class MessagesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var conversation: Conversation!
    var currentPage: Int = 0
    var countPerPage: Int = 10
    var inputText: UITextField!
    var refresher: UIRefreshControl!
    var containerBottomAnchor: NSLayoutConstraint? //for show keyboard animation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: chatMessageCellId)
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        
        navigationItem.title = "Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send Image", style: .plain, target: self, action: #selector(sendNewImageMessage))
        
        setupRefreshControl()
        setupInputComponent()
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMessagesForPage()
    }
    
    func loadMessagesForPage() {
        ChatService.shared.fetchMesagesInCache(conversationId: conversation.id, count: countPerPage, page: currentPage) { messages in
            let newMessages = messages.sorted { $0.date < $1.date }
            self.conversation.addMessagesToFront(newMessages)
            self.currentPage += 1
            
            reloadData()
        }
        
        refresher.endRefreshing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: Setup Views with Constraints
    
    func setupRefreshControl() {
        refresher = UIRefreshControl()
        refresher.tintColor = .lightGray
        refresher.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.refreshControl = refresher
    }
    
    func handleRefreshControl() {
        let time = DispatchTime.now() + 1.5 //for loading effect
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.loadMessagesForPage()
        }
    }
    
    func setupInputComponent() {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        container.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerBottomAnchor = container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerBottomAnchor?.isActive = true
        container.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendNewTextMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        
        //
        inputText = UITextField()
        inputText.placeholder = "Enter text..."
        inputText.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inputText)
        
        inputText.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8).isActive = true
        inputText.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        inputText.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputText.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboarWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboarDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboarWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboarWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            
            containerBottomAnchor?.constant = -keyboardFrame.height
            
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func handleKeyboarDidShow(notification: Notification) {
        scrollToBottom()
    }
    
    func handleKeyboarWillHide(notification: Notification) {
        containerBottomAnchor?.constant = 0
    }
    
    
    // MARK: Send Messages
    
    func sendNewTextMessage() {
        view.endEditing(true)
        
        if let text = inputText.text, !text.isEmpty {
            let message = ChatMessage(type: .text, text: text)
            
            ChatService.shared.sendMessage(message, conversationId: conversation.id) {
                self.conversation.addMessage(message)
                
                let indexPath = IndexPath(item: self.conversation.messages.count-1, section: 0)
                collectionView?.insertItems(at: [indexPath])
                scrollToBottom()
                
                inputText.text = nil
            }
        }
    }
    
    func sendNewImageMessage() {
        let screenSize = UIScreen.main.bounds.size
        
        let size = CGSize(width: random(screenSize.width - 100),
                          height: random(screenSize.height - 400))
        
        let message = ChatMessage(type: .image, text: nil, imageSize: size)
        
        ChatService.shared.sendMessage(message, conversationId: conversation.id) {
            self.conversation.addMessage(message)
            
            let indexPath = IndexPath(item: self.conversation.messages.count-1, section: 0)
            collectionView?.insertItems(at: [indexPath])
            scrollToBottom()
        }
    }
    
    private func reloadData() {
        collectionView?.reloadData()
    }
    
    private func scrollToBottom() {
        let countMessages = conversation.messages.count
        
        if countMessages > 0 {
            let indexPath = IndexPath(item: countMessages-1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversation.messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatMessageCellId, for: indexPath) as! ChatMessageCell
    
        let message = conversation.messages[indexPath.item]
        cell.message = message
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameFor(text: text).width + 24
        }
        
        if let size = message.imageSize {
            cell.imageWidthAnchor?.constant = size.width - 16
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = conversation.messages[indexPath.item]
        var height: CGFloat = 24
        
        switch message.type {
        case .text:
            if let text = message.text {
                height = estimateFrameFor(text: text).height
            }
        case .image:
            if let size = message.imageSize {
                height = size.height
            }
        }
        
        return CGSize(width: view.frame.width, height: height + 20)
    }
    
}


// MARK: Utils

extension MessagesViewController {

    fileprivate func estimateFrameFor(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)],
                                                   context: nil)
    }
    
    fileprivate func random(_ number: CGFloat) -> Int {
        return Int(arc4random_uniform(UInt32(number)) + 100)
    }

}
