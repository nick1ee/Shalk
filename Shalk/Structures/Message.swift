//
//  Message.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/3.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct Message {

    var text: String

    var senderId: String

    var time: Int

}

extension Message {

    typealias MessageObject = [String: Any]

    enum FetchMessageError: Error {

        case invalidMessageObject, missingText, missingSenderId, missingTime

    }

    struct Schema {

        static let text = "text"

        static let senderId = "senderId"

        static let time = "time"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? MessageObject else {

            throw FetchMessageError.invalidMessageObject

        }

        guard let text = jsonObject[Schema.text] as? String else {

            throw FetchMessageError.missingText

        }

        self.text = text

        guard let senderId = jsonObject[Schema.senderId] as? String else {

            throw FetchMessageError.missingSenderId

        }

        self.senderId = senderId

        guard let time = jsonObject[Schema.time] as? Int else {

            throw FetchMessageError.missingTime

        }

        self.time = time

    }

    init(text: String) {

        self.text = text

        let uid = UserManager.shared.currentUser?.uid

        self.senderId = uid!

        self.time = Int(Date().timeIntervalSince1970 * 1000.0)

    }

    func toDictionary() -> MessageObject {

        let messageInfo: [String: Any] = [Schema.text: self.text,

                                          Schema.senderId: self.senderId,

                                          Schema.time: self.time]

        return messageInfo

    }

}
