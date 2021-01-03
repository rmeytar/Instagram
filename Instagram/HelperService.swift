//
//  HelperService.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 29/12/2020.
//

import Foundation
import FirebaseStorage

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
        
        
        storageRef.putData(videoUrl.dataRepresentation, metadata: nil) {(metadata, error) in
//        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
            }
            storageRef.downloadURL { (url, error) in
                if let videoUrl = url?.absoluteString {
                    onSuccess(videoUrl)
                }
            }
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
        
        var dict = ["uid": currentUserId, "photoUrl": photoUrl, "caption": caption, "likeCount": 0,"ratio": ratio] as [String : Any]
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
