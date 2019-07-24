//
//  ChatLogVC.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 16/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK : - Declaration
    private let cellId = "cellId";
    var messages = [Message]();
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name;
            
            observeForMessages();
        }
    }
    
    let messageInputTextContainer: UIView = {
        let containerView = UIView();
        containerView.backgroundColor = .white;
        return containerView;
    }();
    
    var messageInputTextContainerbottomConstraint: NSLayoutConstraint?
    
    let inputTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Enter Message....";
        return tf;
    }();
    
    lazy var sendButton: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system);
        btn.setTitle("Send", for: UIControl.State.normal);
        let titleColor = UIColor(r: 0, g: 137, b: 249);
        btn.setTitleColor(titleColor, for: UIControl.State.normal);
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16);
        btn.addTarget(self, action: #selector(sendMessage), for: UIControl.Event.touchUpInside);
        return btn;
    }();
    
    // MARK : - Action
    @objc func sendMessage() {
        let dbRef = Database.database().reference();
        let userReference = dbRef.child("messages").childByAutoId();
        
        let toId = user!.id;
        guard let fromId = Auth.auth().currentUser?.uid else {
            return;
        }
        let timestamp = Int(NSDate().timeIntervalSince1970);
        let values = ["text": inputTextField.text!,
                      "to_id": toId!,
                      "from_id": fromId,
                      "time_stamp": timestamp] as [String : Any];
        
        userReference.updateChildValues(values as [AnyHashable : Any]) { (error, ref) in
            if error != nil {
                print(error.debugDescription);
                return;
            }
            self.inputTextField.text = nil;
            guard let messageId = userReference.key else {
                return;
            }
            let userMessgesRef = dbRef.child("user_messages").child(fromId);
            userMessgesRef.updateChildValues([messageId : 1]);
            
            let recepientUserMessagesRef = dbRef.child("user_messages").child(toId!);
            recepientUserMessagesRef.updateChildValues([messageId : 1]);
        }
    }
    
    // MARK : - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        inputTextField.delegate = self;
        
        collectionView.backgroundColor = .white;
        collectionView.alwaysBounceVertical = true;
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0);
        collectionView.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId);
        
        view.addSubview(messageInputTextContainer);
        view.addConstraintsWithVisual(format: "H:|[v0]|", views: messageInputTextContainer);
        view.addConstraintsWithVisual(format: "V:[v0(48)]", views: messageInputTextContainer);
        
        messageInputTextContainerbottomConstraint = NSLayoutConstraint(item: messageInputTextContainer, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0);
        view.addConstraint(messageInputTextContainerbottomConstraint!);
        
        setupInputsContainerView();
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        NotificationCenter.default.removeObserver(self);
    }
    
    // MARK : - Setup UI
    func setupInputsContainerView() {
        let topBorderLine = UIView();
        topBorderLine.backgroundColor = UIColor(white: 0.5, alpha: 0.5);
        
        messageInputTextContainer.addSubview(inputTextField);
        messageInputTextContainer.addSubview(sendButton);
        messageInputTextContainer.addSubview(topBorderLine);
        
        messageInputTextContainer.addConstraintsWithVisual(format: "H:|-8-[v0][v1(50)]|", views: inputTextField, sendButton);
        messageInputTextContainer.addConstraintsWithVisual(format: "V:|[v0]|", views: inputTextField);
        messageInputTextContainer.addConstraintsWithVisual(format: "V:|[v0]|", views: sendButton);
        messageInputTextContainer.addConstraintsWithVisual(format: "H:|[v0]|", views: topBorderLine);
        messageInputTextContainer.addConstraintsWithVisual(format: "V:|[v0(0.5)]", views: topBorderLine);
    }
    
    @objc func handleKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue;
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification;
            messageInputTextContainerbottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0;
            
            let keyboardDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey];
            UIView.animate(withDuration: keyboardDuration as! TimeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded();  /* to animate any constraint */
            }) { (completed) in
                /* scroll to the last message */
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0);
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true);
            }
        }
    }
    
    // MARK : - Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage();
        return true;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell;
        
        let message = messages[indexPath.item];
        cell.messageTextView.text = message.text;
        
        /* change bubble colors from sender & recepient */
        setupChatLog(cell: cell, message: message);
        
        /* Modifying the width of the view based on the text size */
        let estimatedFrame = estimatedFrameFor(text: message.text!);
        cell.textBubbleViewWidthAnchor?.constant = estimatedFrame.width + 32;
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messageText = messages[indexPath.item].text else {
            return .zero;
        }
        let estimatedFrame = estimatedFrameFor(text: messageText);
        return CGSize(width: view.frame.width, height: estimatedFrame.height + 20);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0);
    }
 
    // MARK : - User Methods
    func observeForMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return;
        }
        let userMessagesRef = Database.database().reference().child("user_messages").child(uid);
        userMessagesRef.observe(DataEventType.childAdded, with: { (snapshot) in
            let messageId = snapshot.key;
            let messageRef = Database.database().reference().child("messages").child(messageId);
            messageRef.observe(DataEventType.value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    var message = Message();
                    message.fromId = dict["from_id"] as? String;
                    message.text = dict["text"] as? String;
                    message.timestamp = dict["time_stamp"] as? Int;
                    message.toId = dict["to_id"] as? String;
                    
                    if message.getChatPartnersId() == self.user?.id {
                        self.messages.append(message);
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData();
                        }
                    }
                }
            }, withCancel: nil);
        }, withCancel: nil);
    }
    
    private func estimatedFrameFor(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000);
        let drawingOptions = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin);
        return NSString(string: text).boundingRect(with: size, options: drawingOptions, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil);
    }
    
    private func setupChatLog(cell: ChatLogCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImagesUsingCache(withUrl: profileImageUrl);
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            /* Outgoing Message, blue bubble */
            cell.textBubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 249);
            cell.messageTextView.textColor = .white;
            cell.profileImageView.isHidden = true;
            /* pin to the right side of the screen */
            cell.textBubbleViewRightAnchor?.isActive = true;
            cell.textBubbleViewLeftAnchor?.isActive = false;
        } else {
            /* Incoming Message. gray bubble */
            cell.textBubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240);
            cell.messageTextView.textColor = .black;
            cell.profileImageView.isHidden = false;
            /* pin to the left side of the screen */
            cell.textBubbleViewRightAnchor?.isActive = false;
            cell.textBubbleViewLeftAnchor?.isActive = true;
        }
    }
    
} // Class
