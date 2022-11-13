//
//  FirebaseUtils.swift
//  InstagramClone
//
//  Created by Mac on 11.11.2022.
//

import Foundation
import Firebase 

extension Database {
    static func fetchUserWithUid(uid: String, completion:  @escaping (User) -> () ) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            print(user.username)
            completion(user)
        }
    }
}
