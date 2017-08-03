//
//  User.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

typealias UserObject = [String: Any]

struct User {

    var name: String

    var uid: String

    var email: String

    var quickbloxID: String

    var imageURL: String

    var intro: String

    var friends: [String: String]

    var chats: [String: String]

    var description: UserObject {

        return ["name": name, "uid": uid, "email": email, "quickbloxID": quickbloxID, "imageURL": imageURL, "intro": intro, "friendList": friends, "chats": chats]

    }

}

extension User {

    enum FetchUserProfileError: Error {

        case invaidJSONObject, missingName, missingUID, missingEmail, missingQBID, missingImageURL, missingIntro, missingFriends, missingChats

    }

    struct Schema {

        static let name = "name"

        static let uid = "uid"

        static let email = "email"

        static let qbID = "quickbloxID"

        static let imageURL = "imageURL"

        static let intro = "intro"

        static let friends = "friendList"

        static let chats = "chats"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? UserObject else {

            throw FetchUserProfileError.invaidJSONObject

        }

        guard let name = jsonObject[Schema.name] as? String else {

            throw FetchUserProfileError.missingName

        }

        self.name = name

        guard let uid = jsonObject[Schema.uid] as? String else {

            throw FetchUserProfileError.missingUID

        }

        self.uid = uid

        guard let email = jsonObject[Schema.email] as? String else {

            throw FetchUserProfileError.missingEmail

        }

        self.email = email

        guard let qbID = jsonObject[Schema.qbID] as? String else {

            throw FetchUserProfileError.missingQBID

        }

        self.quickbloxID = qbID

        guard let imageURL = jsonObject[Schema.imageURL] as? String else {

            throw FetchUserProfileError.missingImageURL

        }

        self.imageURL = imageURL

        guard let intro = jsonObject[Schema.intro] as? String else {

            throw FetchUserProfileError.missingIntro

        }

        self.intro = intro

        guard let friends = jsonObject[Schema.friends] as? [String: String] else {

            throw FetchUserProfileError.missingFriends

        }

        self.friends = friends

        guard let chats = jsonObject[Schema.chats] as? [String: String] else {

            throw FetchUserProfileError.missingChats

        }

        self.chats = chats

    }

}
