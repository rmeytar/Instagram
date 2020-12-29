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
    
    func observePost(withId id: String, completion: @escaping (Post)->Void) {
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeLikeCount(withPostId id: String, completion: @escaping (Int)->Void) {
        REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        })
    }
    
    func incrementLikes(postId: String, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        let postRef = Api.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.User.CURRENT_USER?.uid {
            var likes: Dictionary<String, Bool>
            likes = post["likes"] as? [String : Bool] ?? [:]
            var likeCount = post["likeCount"] as? Int ?? 0
            if let _ = likes[uid] {
              // Unlike the post and remove self from likes
                likeCount -= 1
                likes.removeValue(forKey: uid)
            } else {
              // Like the post and add self to likes
                likeCount += 1
                likes[uid] = true
            }
            post["likeCount"] = likeCount as AnyObject?
            post["likes"] = likes as AnyObject?
            // Set value and report transaction success
            currentData.value = post
            return TransactionResult.success(withValue: currentData)
          }
          return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
          if let error = error {
            onError(error.localizedDescription)
          }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSuccess(post)
            }
        }
    }
}
