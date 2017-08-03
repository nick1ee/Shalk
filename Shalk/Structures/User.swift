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

}

extension User {

    enum FetchUserProfileError: Error {

        case invaidJSONObject, missingName, missingUID, missingEmail, missingQBID, missingImageURL, missingIntro

    }

    struct Schema {

        static let name = "name"

        static let uid = "uid"

        static let email = "email"

        static let qbID = "quickbloxID"

        static let imageURL = "imageURL"

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

    }

    func toDictionary() -> [String: String] {

        let userInfo: [String: String] = [Schema.name: self.name, Schema.uid: self.uid, Schema.email: self.email, Schema.qbID: self.quickbloxID, Schema.imageURL: self.imageURL, Schema.intro: self.intro]

        return userInfo

    }

}
