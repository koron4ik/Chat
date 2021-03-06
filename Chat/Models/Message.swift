//
//  Message.swift
//  Chat
//
//  Created by Vadim Koronchik on 4/19/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import MessageKit
import CoreLocation
import FirebaseDatabase

private struct CoordinateItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

class Message: MessageType {
    
    var sender: Sender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var text: String
    var wasRead: Bool
    
    private init(kind: MessageKind,
                 text: String,
                 sender: Sender,
                 messageId: String,
                 date: Date,
                 wasRead: Bool = false) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.text = text
        self.wasRead = wasRead
    }
    
//    init(custom: Any?, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
//    }
    
    convenience init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), text: text, sender: sender, messageId: messageId, date: date)
    }
    
    init?(data: Any, id: String) {
        guard let value = data as? [String: Any],
            let senderId = value["senderId"] as? String,
            let senderUsername = value["senderUsername"] as? String,
            let text = value["text"] as? String,
            let dateStr = value["date"] as? String,
            let dateSince1970 = TimeInterval(dateStr),
            let wasRead = value["wasRead"] as? Bool else {
                return nil
        }
        
        self.sender = Sender(id: senderId, displayName: senderUsername)
        self.text = text
        self.kind = .text(text)
        self.sentDate = Date(timeIntervalSince1970: dateSince1970)
        self.messageId = id
        self.wasRead = wasRead
    }
    
//    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
//    }
//
//    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
//        let mediaItem = ImageMediaItem(image: image)
//        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
//    }
//
//    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
//        let mediaItem = ImageMediaItem(image: thumbnail)
//        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
//    }
//
//    init(location: CLLocation, sender: Sender, messageId: String, date: Date) {
//        let locationItem = CoordinateItem(location: location)
//        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
//    }
//
//    init(emoji: String, sender: Sender, messageId: String, date: Date) {
//        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
//    }
    
    func toAny() -> Any {
        return [
            "date": String(sentDate.timeIntervalSince1970),
            "text": text,
            "senderId": sender.id,
            "senderUsername": sender.displayName,
            "wasRead": wasRead
        ]
    }
}

extension Message: Comparable {
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func <(lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
    static func >(lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
