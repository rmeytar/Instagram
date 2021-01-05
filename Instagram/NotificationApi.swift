//
//  NotificationApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 05/01/2021.
//

import Foundation
import FirebaseDatabase

class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotifications(withId id: String, completion: @escaping (Notifications)->Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]
            {
                let newNoti = Notifications.transform(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        })
    }

}
