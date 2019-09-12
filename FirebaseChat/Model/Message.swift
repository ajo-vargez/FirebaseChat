//
//  Message.swift
//  FirebaseChat
//
//  Created by Ajo M Varghese on 16/11/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import Foundation
import Firebase

struct Message {

  var fromId: String?
  var text: String?
  var timestamp: Int?
  var toId: String?

  func getChatPartnersId() -> String? {
    guard let uid = Auth.auth().currentUser?.uid else {
      let err = "Error";
      return err;
    }
    return fromId == uid ? toId! : fromId!;
  }

} // Struct
