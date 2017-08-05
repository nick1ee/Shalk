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

    var user1: String

    var user2: String

    var latestMessage: String

}

extension ChatRoom {

    typealias RoomObject = [String: String]

    enum FetchChatRoomError: Error {

        case invalidChatRoomObject, missingRoomId, missingUser1, missingUser2, missingLatestMessage

    }

    struct Schema {

        static let roomId = "roomId"

        static let user1 = "user1"

        static let user2 = "user2"

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

        guard let user1 = jsonObject[Schema.user1] else {

            throw FetchChatRoomError.missingUser1

        }

        self.user1 = user1

        guard let user2 = jsonObject[Schema.user2] else {

            throw FetchChatRoomError.missingUser2

        }

        self.user2 = user2

        guard let text = jsonObject[Schema.latestMessage] else {

            throw FetchChatRoomError.missingLatestMessage

        }

        self.latestMessage = text

    }

    func toDictionary() -> RoomObject {

        let roomInfo = [Schema.roomId: self.roomId,

                        Schema.user1: self.user1,

                        Schema.user2: self.user2,

                        Schema.latestMessage: self.latestMessage]

        return roomInfo

    }

}
