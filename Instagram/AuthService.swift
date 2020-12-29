//
//  AuthService.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 14/12/2020.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
class AuthService {
    
    static func signIn(email: String, password: String, onSuccess: @escaping ()->Void, onError: @escaping (_ errorMessage: String)->Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping ()->Void, onError: @escaping (_ errorMessage: String?)->Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            let uid = authResult?.user.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil {
                    return
                }
                storageRef.downloadURL(completion: { (url,error) in
                    let profileImageUrl = url?.absoluteString
                    
                    self.setUserInformation(profileImageUrl: profileImageUrl!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                })
            })
        })
    }
    
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping ()->Void){
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl ])
        onSuccess()
    }
    
    static func logOut(onSuccess: @escaping ()->Void, onError: @escaping (_ errorMessage: String?)->Void) {
        do{
            try Auth.auth().signOut()
            onSuccess()
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
}
