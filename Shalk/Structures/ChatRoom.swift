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

    var user1Name: String

    var user1Id: String

    var user2Name: String

    var user2Id: String

    var latestMessage: String

}

extension ChatRoom {

    typealias RoomObject = [String: String]

    enum FetchChatRoomError: Error {

        case invalidChatRoomObject, missingRoomId, missingUser1Name, missingUser1Id, missingUser2Name, missingUser2Id, missingLatestMessage

    }

    struct Schema {

        static let roomId = "roomId"

        static let user1Name = "user1Name"

        static let user1Id = "user1Id"

        static let user2Name = "user2Name"

        static let user2Id = "user2Id"

        static let latestMessage = "latestMessage"
    }

    init(json: Any) throws {

        guard let jsonObject = json as? [String: String] else {

            throw FetchChatRoomError.invalidChatRoomObject

        }

        guard let roomId = jsonObject[Schema.roomId] else {

            throw FetchChatRoomError.missingRoomId

        }

        self.roomId = roomId

        guard let user1Name = jsonObject[Schema.user1Name] else {

            throw FetchChatRoomError.missingUser1Name

        }

        self.user1Name = user1Name

        guard let user1Id = jsonObject[Schema.user1Id] else {

            throw FetchChatRoomError.missingUser1Id

        }

        self.user1Id = user1Id

        guard let user2Name = jsonObject[Schema.user2Name] else {

            throw FetchChatRoomError.missingUser2Name

        }

        self.user2Name = user2Name

        guard let user2Id = jsonObject[Schema.user2Id] else {

            throw FetchChatRoomError.missingUser2Id

        }

        self.user2Id = user2Id

        guard let text = jsonObject[Schema.latestMessage] else {

            throw FetchChatRoomError.missingLatestMessage

        }

        self.latestMessage = text

    }

    init(roomId: String, opponent: User) {

        let me = UserManager.shared.currentUser

        self.roomId = roomId

        self.user1Name = me!.name

        self.user1Id = me!.uid

        self.user2Name = opponent.name

        self.user2Id = opponent.uid

        self.latestMessage = ""

    }

    func toDictionary() -> RoomObject {

        let roomInfo = [Schema.roomId: self.roomId,

                        Schema.user1Name: self.user1Name,

                        Schema.user1Id: self.user1Id,

                        Schema.user2Name: self.user2Name,

                        Schema.user2Id: self.user2Id,

                        Schema.latestMessage: self.latestMessage]

        return roomInfo

    }

}
