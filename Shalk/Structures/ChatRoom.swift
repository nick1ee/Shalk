//
//  ChatRoom.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/5.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct ChatRoom {

    var roomId: String

    var user1Id: String

    var user2Id: String

    var latestMessage: String

    var latestMessageTime: String

}

extension ChatRoom {

    typealias RoomObject = [String: String]

    enum FetchChatRoomError: Error {

        case invalidChatRoomObject, missingRoomId, missingUser1Id, missingUser2Id, missingLatestMessage, missingLatestMessageTime

    }

    struct Schema {

        static let roomId = "roomId"

        static let user1Id = "user1Id"

        static let user2Id = "user2Id"

        static let latestMessage = "latestMessage"

        static let latestMessageTime = "lastestMessageTime"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? [String: String] else {

            throw FetchChatRoomError.invalidChatRoomObject

        }

        guard let roomId = jsonObject[Schema.roomId] else {

            throw FetchChatRoomError.missingRoomId

        }

        self.roomId = roomId

        guard let user1Id = jsonObject[Schema.user1Id] else {

            throw FetchChatRoomError.missingUser1Id

        }

        self.user1Id = user1Id

        guard let user2Id = jsonObject[Schema.user2Id] else {

            throw FetchChatRoomError.missingUser2Id

        }

        self.user2Id = user2Id

        guard let text = jsonObject[Schema.latestMessage] else {

            throw FetchChatRoomError.missingLatestMessage

        }

        self.latestMessage = text

        guard let time = jsonObject[Schema.latestMessageTime] else {

            throw FetchChatRoomError.missingLatestMessageTime

        }

        self.latestMessageTime = time

    }

    init(roomId: String, opponent: User) {

        let me = UserManager.shared.currentUser

        self.roomId = roomId

        self.user1Id = me!.uid

        self.user2Id = opponent.uid

        self.latestMessage = ""

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        self.latestMessageTime = timestamp

    }

    func toDictionary() -> RoomObject {

        let roomInfo = [Schema.roomId: self.roomId,

                        Schema.user1Id: self.user1Id,

                        Schema.user2Id: self.user2Id,

                        Schema.latestMessage: self.latestMessage,

                        Schema.latestMessageTime: self.latestMessageTime]

        return roomInfo

    }

}
