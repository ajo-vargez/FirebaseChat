//
//  MainVC.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 13/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UITableViewController {

  // MARK : - Declaration
  var messages = [Message]();
  var messagesDictionary = [String: Message]();
  var timer: Timer?

  private let cellId = "cellId";

  // MARK : - Actions
  @objc func handleSignOut() {
    do {
      try Auth.auth().signOut();
    } catch let signoutErr {
      print(signoutErr);
    }
    let loginVC = LoginVC();
    loginVC.mainVC = self;
    present(loginVC, animated: true, completion: nil);
  }

  @objc func createNewMessage() {
    let newMessageVC = NewMessageVC();
    newMessageVC.mainVC = self;
    let navController = UINavigationController(rootViewController: newMessageVC);
    present(navController, animated: true, completion: nil);
  }

  // MARK : - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad();

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SignOut", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleSignOut));
    let newMessageIcon = UIImage(named: "new_message_icon");
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageIcon, style: UIBarButtonItem.Style.plain, target: self, action: #selector(createNewMessage));

    tableView.register(UserCell.self, forCellReuseIdentifier: cellId);
    tableView.tableFooterView = UIView();

    /* check if user is logged in */
    checkIfUserIsloggedIn();
  }

  // MARK : - Custom methods
  func checkIfUserIsloggedIn() {
    if Auth.auth().currentUser?.uid == nil {
      perform(#selector(handleSignOut), with: nil, afterDelay: 0);        /* to avoid presenting too many VC's at start, therefore using a '0' second delay */
    } else {
      setupNavbarTitle();
    }
  }

  func setupNavbarTitle() {
    messages.removeAll();       /* to clean up previous chats */
    messagesDictionary.removeAll();
    tableView.reloadData();

    guard let uid = Auth.auth().currentUser?.uid else {
      return;
    }

    /* check for new (or) older messages */
    observeForUserMessages(uid: uid);

    Database.database().reference().child("users").child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
      if let dict = snapshot.value as? [String: AnyObject] {
        self.navigationItem.title = dict["name"] as? String;
      }
    }, withCancel: nil);
  }

  func observeForUserMessages(uid: String) {
    let dbRef = Database.database().reference().child("user_messages").child(uid);
    dbRef.observe(DataEventType.childAdded, with: { (snapshot) in
      let messageId = snapshot.key;
      let messagesRef = Database.database().reference().child("messages").child(messageId);
      messagesRef.observe(DataEventType.value, with: { (snapshot) in
        if let dict = snapshot.value as? [String: AnyObject] {
          var message = Message();
          message.fromId = dict["from_id"] as? String;
          message.text = dict["text"] as? String;
          message.timestamp = dict["time_stamp"] as? Int;
          message.toId = dict["to_id"] as? String;

          /* message.setValuesForKeys(dict) would work if struct is replaced by class:NSObject in the model */
          /* self.messages.append(message) */

          /* to display messages in a sorted based on time */
          if let id = message.getChatPartnersId() {
            self.messagesDictionary[id] = message;
            self.messages = Array(self.messagesDictionary.values);
            self.messages.sort(by: { (messageOne, messageTwo) -> Bool in
              return messageOne.timestamp! > messageTwo.timestamp!;
            });
          }
          /* to remove image flickering while reloading tableview */
          self.timer?.invalidate();
          self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableViewReload), userInfo: nil, repeats: false);
        }
      }, withCancel: nil);
    }, withCancel: nil);
  }

  @objc func handleTableViewReload() {
    DispatchQueue.main.async {
      self.tableView.reloadData();
    }
  }

  func showChatLogForUser(user: User) {
    let layout = UICollectionViewFlowLayout();
    let chatVC = ChatLogVC(collectionViewLayout: layout);
    chatVC.user = user;
    navigationController?.pushViewController(chatVC, animated: true);
  }

  // MARK : - Delegate Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count;
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell;

    let message = messages[indexPath.row];
    cell.message = message;

    return cell;
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72;
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row];
    guard let id = message.getChatPartnersId() else {
      return;
    }
    let ref = Database.database().reference().child("users").child(id);
    ref.observe(DataEventType.value, with: { (snapshot) in
      if let dict = snapshot.value as? [String: AnyObject] {
        var user = User();
        user.name = dict["name"] as? String;
        user.email = dict["email"] as? String;
        user.profileImageUrl = dict["profile_image"] as? String;
        user.id = id;

        self.showChatLogForUser(user: user);
      }
    }, withCancel: nil);
  }

} // Class

