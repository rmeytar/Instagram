//
//  Notification.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 05/01/2021.
//

import Foundation

class Notifications {
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
}

extension Notifications {
    static func transform(dict: [String: Any], key: String) -> Notifications {
        let notifi = Notifications()
        notifi.id = key
        notifi.objectId = dict["objectId"] as? String
        notifi.type = dict["type"] as? String
        notifi.timestamp = dict["timestamp"] as? Int
        notifi.from = dict["from"] as? String
        
        return notifi
    }
}


