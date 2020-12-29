//
//  MyPostsApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 28/12/2020.
//

import Foundation
import FirebaseDatabase

class MyPostsApi {
    var REF_MYPOSTS = Database.database().reference().child("myPosts")
    
}
