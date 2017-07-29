//
//  ConversationsViewController.swift
//  chattest
//
//  Created by Guest User on 5/29/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit

private let conversationCellId = "cellId"

class ConversationsViewController: UITableViewController {

    var conversationIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Chat", style: .plain, target: self, action: #selector(newConversation))
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func newConversation() {
        let conversationId = "\(conversationIds.count)"
        
        conversationIds.append(conversationId)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: conversationCellId, for: indexPath)
        
        let conversationId = conversationIds[indexPath.row]
        cell.textLabel?.text = "Conversation #" + conversationId
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationId = conversationIds[indexPath.row]
        
        showMessagesViewController(conversationId: conversationId)
    }
    
    func showMessagesViewController(conversationId: String) {
        let controller = MessagesViewController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.conversation = Conversation(id: conversationId)
        
        navigationController?.pushViewController(controller, animated: true)
    }

}
