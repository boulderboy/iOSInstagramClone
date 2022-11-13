//
//  User.swift
//  InstagramClone
//
//  Created by Mac on 11.11.2022.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String,  dictionary: [String: Any]) {
        self.uid = uid
        username = dictionary["username"] as? String ?? ""
        profileImageUrl = dictionary["userImage"] as? String ?? ""
    }
}
