//
//  ChatLogCell.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 20/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit

class ChatLogCell: UICollectionViewCell {
  
  // MARK : - Declaration
  let messageTextView: UITextView = {
    let messageText = UITextView();
    messageText.font = UIFont.systemFont(ofSize: 16);
    messageText.isEditable = false;
    messageText.backgroundColor = .clear;
    messageText.translatesAutoresizingMaskIntoConstraints = false;
    return messageText;
  }();
  
  let textBubbleView: UIView = {
    let view = UIView();
    view.layer.cornerRadius = 16;
    view.layer.masksToBounds = true;
    view.translatesAutoresizingMaskIntoConstraints = false;
    return view;
  }();
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView();
    imageView.contentMode = .scaleAspectFill;
    imageView.layer.cornerRadius = 16;
    imageView.layer.masksToBounds = true;
    imageView.translatesAutoresizingMaskIntoConstraints = false;
    return imageView;
  }();
  
  var textBubbleViewWidthAnchor: NSLayoutConstraint?
  var textBubbleViewRightAnchor: NSLayoutConstraint?
  var textBubbleViewLeftAnchor: NSLayoutConstraint?
  
  // MARK : - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame);
    
    setupViews();
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  }
  
  // MARK : - setup UI
  func setupViews() {
    addSubview(textBubbleView);
    addSubview(messageTextView);
    addSubview(profileImageView);
    
    /* Bubble View */
    NSLayoutConstraint.activate([textBubbleView.topAnchor.constraint(equalTo: self.topAnchor),
                                 textBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)]);
    textBubbleViewRightAnchor = textBubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8);
    textBubbleViewLeftAnchor = textBubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8);
    textBubbleViewWidthAnchor = textBubbleView.widthAnchor.constraint(equalToConstant: 200);
    textBubbleViewWidthAnchor?.isActive = true;
    /* Text View */
    NSLayoutConstraint.activate([messageTextView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor, constant: 8),
                                 messageTextView.topAnchor.constraint(equalTo: self.topAnchor),
                                 messageTextView.rightAnchor.constraint(equalTo: textBubbleView.rightAnchor),
                                 messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor)]);
    /* profile image */
    NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                                 profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                 profileImageView.widthAnchor.constraint(equalToConstant: 32),
                                 profileImageView.heightAnchor.constraint(equalToConstant: 32)]);
  }
  
} // Class
