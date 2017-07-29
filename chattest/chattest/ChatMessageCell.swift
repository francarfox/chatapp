//
//  ChatMessageCell.swift
//  chattest
//
//  Created by Technorides on 5/30/17.
//  Copyright © 2017 Guest User. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    var message: ChatMessage? {
        didSet {
            if let text = message?.text {
                textView.text = text
                
                imageView.isHidden = true
                textView.isHidden = false
                bubbleView.isHidden = false
            }
            
            if let imageUrl = message?.imageUrl {
                imageView.isHidden = false
                textView.isHidden = true
                bubbleView.isHidden = true
                
                imageView.image = nil
                ChatService.shared.loadImage(withUrl: imageUrl) { image in
                    self.imageView.image = image
                    self.layoutSubviews()
                }
            }
        }
    }
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageWidthAnchor: NSLayoutConstraint?
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(bubbleView)
        addSubview(textView)
        
        setupViews()
    }
    
    func setupViews() {
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        imageWidthAnchor = imageView.widthAnchor.constraint(equalToConstant: 200)
        imageWidthAnchor?.isActive = true
        
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

