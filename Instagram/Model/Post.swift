//
//  Post.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 16/12/2020.
//

import Foundation

class Post {
    var caption: String?
    var photoUrl: String?
    var uid: String?
    
}

extension Post {
    static func transformPostPhoto(dict: [String: Any]) -> Post {
        let post = Post()
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.uid = dict["uid"] as? String
        return post
    }
    
    static func transformPostVideo() {
        
    }
}
