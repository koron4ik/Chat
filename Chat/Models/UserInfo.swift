//
//  User.swift
//  Chat
//
//  Created by Vadim Koronchik on 3/19/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class UserInfo {
    
    var phoneNumber: String
    var imageUrl: URL
    var userId: String
    var username: String
    
    init?(data: Any) {
        guard let info = data as? [String: Any],
            let phoneNumber = info["phoneNumber"] as? String,
            let imageUrlString = info["imageUrl"] as? String,
            let imageUrl = URL(string: imageUrlString),
            let userId = info["userId"] as? String,
            let username = info["username"] as? String else {
                return nil
        }
        
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.userId = userId
        self.username = username
    }
    
    init(phoneNumber: String, imageUrl: URL, userId: String, username: String) {
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.userId = userId
        self.username = username
    }
    
    func toAny() -> Any {
        return [
            "phoneNumber": phoneNumber,
            "imageUrl": imageUrl.absoluteString,
            "userId": userId,
            "username": username
        ]
    }
}
