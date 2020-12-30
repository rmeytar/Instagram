//
//  HelperService.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 29/12/2020.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    static func uploadDataToServer(data: Data, caption: String, onSuccess: @escaping () -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil, completion: {(metadata, error) in
            storageRef.downloadURL(completion: { (url,error) in
                let photoUrl = url?.absoluteString
                self.sendDataToDatabase(photoUrl: photoUrl!, caption: caption, onSuccess: onSuccess)
            })
        })
    }
    
    static func sendDataToDatabase(photoUrl: String, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key!
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newPostReference.setValue(["uid": currentUserId, "photoUrl": photoUrl, "caption": caption], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            //showing only the post of people i follow
            Database.database().reference().child("feed").child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            
            let myPostRef =  Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(true) { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            }
            
            ProgressHUD.showSuccess("Success")
            onSuccess()
        })
    }
}
