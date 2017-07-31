//
//  OpponentUserStructure.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/31.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct Opponent {

    var name: String

    var quickbloxID: Int

    var imageURL: String

    var description: UserObject {

        return ["name": name, "quickbloxID": quickbloxID, "imageURL": imageURL]

    }

}

extension Opponent {

    enum GetOpponentInfo: Error {

        case invaidJSONObject, missingName, missingQBID, missingImageURL

    }

    struct Schema {

        static let name = "name"

        static let qbID = "quickbloxID"

        static let imageURL = "imageURL"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? UserObject else {

            throw GetOpponentInfo.invaidJSONObject

        }

        guard let name = jsonObject[Schema.name] as? String else {

            throw GetOpponentInfo.missingName

        }

        self.name = name

        guard let qbID = jsonObject[Schema.qbID] as? Int else {

            throw GetOpponentInfo.missingQBID

        }

        self.quickbloxID = qbID

        guard let imageURL = jsonObject[Schema.imageURL] as? String else {

            throw GetOpponentInfo.missingImageURL

        }

        self.imageURL = imageURL

    }

}
