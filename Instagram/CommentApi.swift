//
//  CommentApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 23/12/2020.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    func observeComments(withPostId id: String, completion: @escaping (Comment)->Void) {
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }
        })
    }
}
