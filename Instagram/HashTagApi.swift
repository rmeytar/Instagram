//
//  HashTagApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 03/01/2021.
//

import Foundation
import FirebaseDatabase

class HashTagApi {
    var REF_HASHTAG = Database.database().reference().child("hashTag")
    
    func fetchPosts(withTag tag: String, completion: @escaping (String) -> Void) {
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
}
