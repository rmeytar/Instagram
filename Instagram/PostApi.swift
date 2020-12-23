//
//  PostApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 23/12/2020.
//

import Foundation
import FirebaseDatabase

//this class handle database tasks realated to posts
class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    
    func observePosts(completion: @escaping (Post)->Void) {
        REF_POSTS.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
}
