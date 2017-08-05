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

    var quickbloxId: String

    var imageUrl: String

    var intro: String

}

extension User {

    enum FetchUserProfileError: Error {

        case invaidJSONObject, missingName, missingUID, missingEmail, missingQuickbloxId, missingImageUrl, missingIntro

    }

    struct Schema {

        static let name = "name"

        static let uid = "uid"

        static let email = "email"

        static let qbID = "quickbloxId"

        static let imageUrl = "imageUrl"

        static let intro = "intro"

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

    func toDictionary() -> [String: String] {

        let userInfo: [String: String] = [Schema.name: self.name,

                                          Schema.uid: self.uid,

                                          Schema.email: self.email,

                                          Schema.qbID: self.quickbloxId,

                                          Schema.imageUrl: self.imageUrl,

                                          Schema.intro: self.intro]

        return userInfo

    }

}
