//
//  NotificationApi.swift
//  Instagram
//
//  Created by Zeev Rozenberg on 04/01/2021.
//

import Foundation
import FirebaseDatabase

class NotificationApi {
    var REF_NOTIFICIATION = Database.database().reference().child("notification")
}
