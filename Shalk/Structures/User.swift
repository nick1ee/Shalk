//
//  User.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - USer

import Foundation

typealias UserObject = [String: Any]

struct User {

    // MARK: Property

    var name: String

    let uid: String

    let email: String

    var quickbloxId: String

    var imageUrl: String

    var intro: String

}

extension User {

    // MARK: FetchUserProfileError

    enum FetchUserProfileError: Error {

        case invaidJSONObject, missingName, missingUID, missingEmail, missingQuickbloxId, missingImageUrl, missingIntro

    }

    // MARK: Schema

    struct Schema {

        static let name = "name"

        static let uid = "uid"

        static let email = "email"

        static let qbID = "quickbloxId"

        static let imageUrl = "imageUrl"

        static let intro = "intro"

    }

    // MARK: Init

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

            throw FetchUserProfileError.missingQuickbloxId

        }

        self.quickbloxId = qbID

        guard let imageUrl = jsonObject[Schema.imageUrl] as? String else {

            throw FetchUserProfileError.missingImageUrl

        }

        self.imageUrl = imageUrl

        guard let intro = jsonObject[Schema.intro] as? String else {

            throw FetchUserProfileError.missingIntro

        }

        self.intro = intro

    }

    init(name: String, uid: String, email: String, quickbloxId: String) {

        self.name = name

        self.uid = uid

        self.email = email

        self.quickbloxId = quickbloxId

        self.imageUrl = "null"

        self.intro = "null"

    }

    typealias UserProfile = [String: String]

    func toDictionary() -> UserProfile {

        let userInfo: UserProfile = [

            Schema.name: self.name,
            Schema.uid: self.uid,
            Schema.email: self.email,
            Schema.qbID: self.quickbloxId,
            Schema.imageUrl: self.imageUrl,
            Schema.intro: self.intro

        ]

        return userInfo

    }

}
