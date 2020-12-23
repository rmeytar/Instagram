//
//  Comment.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 23/12/2020.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
    
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }

}

