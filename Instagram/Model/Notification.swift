//
//  Notification.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 04/01/2021.
//

import Foundation
import FirebaseAuth

class Notification {
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
    
}

extension Notification {
    static func transformPostPhoto(dict: [String: Any], key: String) -> Notification {
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        
        return notification
    }
}


