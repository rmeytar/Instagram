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
    var id: String?
    
}

extension Post {
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.uid = dict["uid"] as? String
        return post
    }
    
    static func transformPostVideo() {
        
    }
}
