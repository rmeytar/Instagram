//
//  Api.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 23/12/2020.
//

import Foundation

struct Api {
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostsApi()
}
