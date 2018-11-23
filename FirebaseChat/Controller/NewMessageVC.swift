//
//  NewMessageVC.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 14/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class NewMessageVC: UITableViewController {
    
    // MARK : - Declaration
    var users = [User]();
    
    private let cellId = "cellid";
    
    var mainVC: MainVC?
    
    // MARK : - Actions
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil);
    }
    
    // MARK : - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        navigationItem.title = "New Message";
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancel));
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId);
        tableView.tableFooterView = UIView();
        
        fetchUserData();
    }
    
    // MARK : - Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell;
        let user = users[indexPath.row];
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email;
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImagesUsingCache(withUrl: profileImageUrl);
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row];
            self.mainVC?.showChatLogForUser(user: user);
        }
    }
    
    // MARK : - Custom Methods
    func fetchUserData() {
        var user = User();
        Database.database().reference().child("users").observe(DataEventType.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                user.id = snapshot.key;
                user.name = dict["name"] as? String;
                user.email = dict["email"] as? String;
                user.profileImageUrl = dict["profile_image"] as? String;
                
                self.users.append(user);
                
                DispatchQueue.main.async {
                    self.tableView.reloadData();
                }
            }
        }, withCancel: nil);
    }
    
} // Class
