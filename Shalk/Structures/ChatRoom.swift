//
//  ChatRoom.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/5.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - ChatROOM

import Foundation

struct ChatRoom {
    
    // MARK: Property

    var roomId: String

    var user1Id: String

    var user2Id: String

    var latestMessage: String

    var latestMessageTime: String

    var isRead: Bool

}

extension ChatRoom {

    typealias RoomObject = [String: Any]

    enum FetchChatRoomError: Error {

        case invalidChatRoomObject, missingRoomId, missingUser1Id, missingUser2Id, missingLatestMessage, missingLatestMessageTime, missingIsRead

    }
    
    // MARK: - Schema

    struct Schema {

        static let roomId = "roomId"

        static let user1Id = "user1Id"

        static let user2Id = "user2Id"

        static let latestMessage = "latestMessage"

        static let latestMessageTime = "latestMessageTime"

        static let isRead = "isRead"

    }
    
    // MARK: Init

    init(json: Any) throws {

        guard let jsonObject = json as? RoomObject else {

            throw FetchChatRoomError.invalidChatRoomObject

        }

        guard let roomId = jsonObject[Schema.roomId] as? String else {

            throw FetchChatRoomError.missingRoomId

        }

        self.roomId = roomId

        guard let user1Id = jsonObject[Schema.user1Id] as? String else {

            throw FetchChatRoomError.missingUser1Id

        }

        self.user1Id = user1Id

        guard let user2Id = jsonObject[Schema.user2Id] as? String else {

            throw FetchChatRoomError.missingUser2Id

        }

        self.user2Id = user2Id

        guard let text = jsonObject[Schema.latestMessage] as? String else {

            throw FetchChatRoomError.missingLatestMessage

        }

        self.latestMessage = text

        guard let time = jsonObject[Schema.latestMessageTime] as? String else {

            throw FetchChatRoomError.missingLatestMessageTime

        }

        self.latestMessageTime = time

        guard let isRead = jsonObject[Schema.isRead] as? Bool else {

            throw FetchChatRoomError.missingIsRead

        }

        self.isRead = isRead

    }

    init(roomId: String, opponent: User) {

        let me = UserManager.shared.currentUser

        self.user1Id = me!.uid

        self.roomId = roomId

        self.user2Id = opponent.uid

        self.latestMessage = ""

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        self.latestMessageTime = timestamp

        self.isRead = true

    }

    func toDictionary() -> RoomObject {

        let roomInfo: RoomObject = [
        
            Schema.roomId: self.roomId,
            Schema.user1Id: self.user1Id,
            Schema.user2Id: self.user2Id,
            Schema.latestMessage: self.latestMessage,
            Schema.latestMessageTime: self.latestMessageTime,
            Schema.isRead: self.isRead
        
        ]

        return roomInfo

    }

}
