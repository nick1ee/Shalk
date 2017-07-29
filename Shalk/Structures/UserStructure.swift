//
//  UserStructure.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

typealias UserObject = [String: Any]

enum PreferredLangauge: String {

    case notSelected

    case english

    case chinese

    case japanese

    case korean

}

struct User {

    var name: String

    var uid: String

    var email: String

    var quickbloxID: Int

    var preferredLanguages: [PreferredLangauge.RawValue]

    var description: UserObject {

        return ["name": name, "uid": uid, "email": email, "quickbloxID": quickbloxID, "preferredLanguages": preferredLanguages]

    }

}

extension User {

    enum FetchUserProfileError: Error {

        case invaidJSONObject, missingName, missingUID, missingEmail, missingQBID, missingPreferredLanguages

    }

    struct Schema {

        static let name = "name"

        static let uid = "uid"

        static let email = "email"

        static let qbID = "quickbloxID"

        static let preferredLanguages = "preferredLanguages"

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

        guard let qbID = jsonObject[Schema.qbID] as? Int else {

            throw FetchUserProfileError.missingQBID

        }

        self.quickbloxID = qbID

        guard let languages = jsonObject[Schema.preferredLanguages] as? [String] else {

            throw FetchUserProfileError.missingPreferredLanguages

        }

        self.preferredLanguages = languages

    }

}
