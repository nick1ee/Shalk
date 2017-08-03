//
//  Message.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/3.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {

    var text: String!

    var senderId: String!

    var userName: String!

    var ref: DatabaseReference!

    var key: String = ""

}

extension Message {

    enum FetchMessageError: Error {

        case defaultError

    }

    init(snapshot: DataSnapshot) throws {

        guard
            let json = snapshot.value as? Any?,
            let jsonObject = json as? [String: Any] else {

            throw FetchMessageError.defaultError

        }

        guard let text = jsonObject["text"] as? String else {

            throw FetchMessageError.defaultError

        }

        self.text = text

        guard let senderId = jsonObject["sender"] as? String else {
            throw FetchMessageError.defaultError

        }

        self.senderId = senderId

        guard let userName = jsonObject["userName"] as? String else {

            throw FetchMessageError.defaultError

        }

        self.userName = userName

        self.ref = snapshot.ref

        self.key = snapshot.key

    }

}
