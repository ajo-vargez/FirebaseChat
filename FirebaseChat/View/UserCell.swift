//
//  UserCell.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 14/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    // MARK : - Declaration
    var message: Message? {
        didSet {
            setupNameAndProfileImage();
            detailTextLabel?.text = message?.text;
            if let seconds = message?.timestamp {
                let dateAndTime = Date(timeIntervalSince1970: TimeInterval(seconds));
                
                let dateFormatter = DateFormatter();
                dateFormatter.dateFormat = "hh:mm a";
                
                timeLabel.text = dateFormatter.string(from: dateAndTime);
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill;
        imageView.layer.cornerRadius = 24;
        imageView.layer.masksToBounds = true;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    let timeLabel: UILabel = {
        let lbl = UILabel();
        lbl.textAlignment = .center;
        lbl.font = UIFont.systemFont(ofSize: 12);
        lbl.textColor = .darkGray;
        lbl.translatesAutoresizingMaskIntoConstraints = false;
        return lbl;
    }();
    
    // MARK : - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier);
        
        setupViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height);
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height);
    }
    
    // MARK : - Setup UI
    func setupViews() {
        addSubview(profileImageView);
        addSubview(timeLabel);
        
        /* profile image view */
        NSLayoutConstraint.activate([profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                                     profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                                     profileImageView.widthAnchor.constraint(equalToConstant: 48),
                                     profileImageView.heightAnchor.constraint(equalToConstant: 48)]);
        /* time label */
        NSLayoutConstraint.activate([timeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                                     timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
                                     timeLabel.widthAnchor.constraint(equalToConstant: 100),
                                     timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!)]);
    }
    
    // MARK : - User Methods
    private func setupNameAndProfileImage() {
        guard let id = message?.getChatPartnersId() else {
            return;
        }
        let dbRef = Database.database().reference().child("users").child(id);
        dbRef.observe(DataEventType.value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                self.textLabel?.text = dict["name"] as? String;
                if let profileImageurl = dict["profile_image"] as? String {
                    self.profileImageView.loadImagesUsingCache(withUrl: profileImageurl);
                }
            }
        }, withCancel: nil);
    }
    
} // Class
