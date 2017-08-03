//
//  Opponent.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/31.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct Opponent {

    var uid: String

    var name: String

    var quickbloxID: String

    var imageURL: String

}

extension Opponent {

    enum GetOpponentInfo: Error {

        case invaidJSONObject, missingUid, missingName, missingQBID, missingImageURL

    }

    struct Schema {

        static let uid = "uid"

        static let name = "name"

        static let qbID = "quickbloxID"

        static let imageURL = "imageURL"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? UserObject else {

            throw GetOpponentInfo.invaidJSONObject

        }

        guard let uid = jsonObject[Schema.uid] as? String else {

            throw GetOpponentInfo.missingUid

        }

        self.uid = uid

        guard let name = jsonObject[Schema.name] as? String else {

            throw GetOpponentInfo.missingName

        }

        self.name = name

        guard let qbID = jsonObject[Schema.qbID] as? String else {

            throw GetOpponentInfo.missingQBID

        }

        self.quickbloxID = qbID

        guard let imageURL = jsonObject[Schema.imageURL] as? String else {

            throw GetOpponentInfo.missingImageURL

        }

        self.imageURL = imageURL

    }

}
