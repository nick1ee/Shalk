//
//  AudioChannel.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/1.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - AudioChannel

import Foundation

struct AudioChannel {

    // MARK: Property

    let roomID: String

    let participant: String

    let owner: String

    let isLocked: Bool

    let isFinished: Bool

}

extension AudioChannel {

    typealias ChannelObject = [String: Any]

    // MARK: ParseChannelError

    enum ParseChannelError: Error {

        case invalidChannelObject, missingRoomID, missingParticipant, missingOwner, missingIsLocked, missingIsFinished

    }

    // MARK: Schema

    struct Schema {

        static let roomID = "roomID"

        static let participant = "participant"

        static let owner = "owner"

        static let isLocked = "isLocked"

        static let isFinished = "isFinished"

    }

    // MARK: Init

    init(json: Any) throws {

        guard let jsonObject = json as? ChannelObject else {

            throw ParseChannelError.invalidChannelObject

        }

        guard let roomID = jsonObject[Schema.roomID] as? String else {

            throw ParseChannelError.missingRoomID

        }

        self.roomID = roomID

        guard let participant = jsonObject[Schema.participant] as? String else {

            throw ParseChannelError.missingParticipant

        }

        self.participant = participant

        guard let owner = jsonObject[Schema.owner] as? String else {

            throw ParseChannelError.missingOwner

        }

        self.owner = owner

        guard let isLocked = jsonObject[Schema.isLocked] as? Bool else {

            throw ParseChannelError.missingIsLocked

        }

        self.isLocked = isLocked

        guard let isFinished = jsonObject[Schema.isFinished] as? Bool else {

            throw ParseChannelError.missingIsFinished

        }

        self.isFinished = isFinished

    }

    init(roomID: String, owner: String) {

        self.roomID = roomID

        self.owner = owner

        self.participant = "null"

        self.isLocked = false

        self.isFinished = false

    }

    func toDictionary() -> ChannelObject {

        let channelInfo: ChannelObject = [

            Schema.roomID: self.roomID,
            Schema.participant: self.participant,
            Schema.owner: self.owner,
            Schema.isLocked: self.isLocked,
            Schema.isFinished: self.isFinished

        ]

        return channelInfo

    }

}
