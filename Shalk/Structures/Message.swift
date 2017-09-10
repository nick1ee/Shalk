//
//  Message.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/3.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: Message.swift

import UIKit

struct Message {

    // MARK: Property

    let text: String

    let senderId: String

    let time: String

}

extension Message {

    typealias MessageObject = [String: String]

    // MARK: FetchMessageError

    enum FetchMessageError: Error {

        case invalidMessageObject, missingText, missingSenderId, missingTime

    }

    // MARK: Schema

    struct Schema {

        static let text = "text"

        static let senderId = "senderId"

        static let time = "time"

    }

    // MARK: Init

    init(json: Any) throws {

        guard let jsonObject = json as? MessageObject else {

            throw FetchMessageError.invalidMessageObject

        }

        guard let text = jsonObject[Schema.text] else {

            throw FetchMessageError.missingText

        }

        self.text = text

        guard let senderId = jsonObject[Schema.senderId] else {

            throw FetchMessageError.missingSenderId

        }

        self.senderId = senderId

        guard let time = jsonObject[Schema.time] else {

            throw FetchMessageError.missingTime

        }

        self.time = time

    }

    init(text: String) {

        self.text = text

        let uid = UserManager.shared.currentUser?.uid

        self.senderId = uid!

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        self.time = timestamp

    }

    func toDictionary() -> MessageObject {

        let messageInfo: MessageObject = [

            Schema.text: self.text,
            Schema.senderId: self.senderId,
            Schema.time: self.time

        ]

        return messageInfo

    }

}
