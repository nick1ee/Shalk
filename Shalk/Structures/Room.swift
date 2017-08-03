//
//  Room.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/1.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct Room {

    let roomID: String

    let participant: String

    let owner: String

    let isLocked: Bool

    let isFinished: Bool

}

extension Room {

    typealias RoomObject = [String: Any]

    enum ParseRoomError: Error {

        case invalidRoomObject, missingRoomID, missingParticipant, missingOwner, missingIsLocked, missingIsFinished

    }

    struct Schema {

        static let roomID = "roomID"

        static let participant = "participant"

        static let owner = "owner"

        static let isLocked = "isLocked"

        static let isFinished = "isFinished"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? RoomObject else {

            throw ParseRoomError.invalidRoomObject

        }

        guard let roomID = jsonObject[Schema.roomID] as? String else {

            throw ParseRoomError.missingRoomID

        }

        self.roomID = roomID

        guard let participant = jsonObject[Schema.participant] as? String else {

            throw ParseRoomError.missingParticipant

        }

        self.participant = participant

        guard let owner = jsonObject[Schema.owner] as? String else {

            throw ParseRoomError.missingOwner

        }

        self.owner = owner

        guard let isLocked = jsonObject[Schema.isLocked] as? Bool else {

            throw ParseRoomError.missingIsLocked

        }

        self.isLocked = isLocked

        guard let isFinished = jsonObject[Schema.isFinished] as? Bool else {

            throw ParseRoomError.missingIsFinished

        }

        self.isFinished = isFinished

    }
    
    init() {
        
        let roomInfo: [String: Any] = ["roomID": id, "participant": "null", "owner": uid, "isLocked": false, "isFinished": false]
        
    }

}
