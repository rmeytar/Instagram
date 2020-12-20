//
//  User.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 20/12/2020.
//

import Foundation

class User {
    var email: String?
    var profileImageUrl: String?
    var username: String?
}

extension User {
    static func transformUser(dict: [String: Any]) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        
        return user
    }
}
