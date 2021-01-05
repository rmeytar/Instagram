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
    static func uploadDataToServer(data: Data,ratio: CGFloat, videoUrl: URL? = nil, caption: String, onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl) { (videoUrl) in
                uploadImageToFirebaseStorage(data: data) { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, ratio: ratio, videoUrl: videoUrl, caption: caption, onSuccess: onSuccess)
                }
            }
            //self.senddatatodatabase
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl,ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        
        
//        storageRef.putData(videoUrl.dataRepresentation, metadata: nil) {(metadata, error) in
        
        storageRef.putFile(from: videoUrl, metadata: nil) { (_, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if let videoUrl = url?.absoluteString {
                    onSuccess(videoUrl)
                }
            })
        }
    }

    static func uploadImageToFirebaseStorage(data: Data ,onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil, completion: {(metadata, error) in
            storageRef.downloadURL(completion: { (url,error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                }
                if let photoUrl = url?.absoluteString {
                    onSuccess(photoUrl)
                }
            })
        })
    }
    
    static func sendDataToDatabase(photoUrl: String,ratio: CGFloat, videoUrl: String? = nil, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key!
        let newPostReference = Api.Post.REF_POSTS.child(newPostId)
        
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashTagRef = Api.HashTag.REF_HASHTAG.child(word.lowercased())
                newHashTagRef.updateChildValues([newPostId: true])
            }
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0,"ratio": ratio, "timestamp": timestamp] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            //showing only the post of people i follow
            Api.Feed.REF_FEED.child(Api.User.CURRENT_USER!.uid).child(newPostId).setValue(true)
            
            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    print(child.key)
                })
            })
            
//            Api.Follow.REF_FOLLOWERS.child(Api.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
//                snapshot in
//                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
//                arraySnapshot.forEach ({ (child) in
//                    print(child.key)
//                    Api.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)": true])
//                    let newNotificationId = Api.notification.REF_NOTIFICIATION.child(child.key).childByAutoId().key
//                    let newNotificationReference = Api.notification.REF_NOTIFICIATION.child(child.key).child(newNotificationId!)
//                    newNotificationReference.setValue(["from": Api.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId, "timestap": timestamp])
//                })
//            })
            
            
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
