//
//  Friend.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/2.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

struct Friend {

    let name: String

    let imageUrl: String

}

extension Friend {

    enum FetchFriendInfoError: Error {

        case invalidJsonObject, missingName, missingImageUrl

    }

    struct Schema {

        static let name = "name"

        static let imageUrl = "imageURL"

    }

    init(json: Any) throws {

        guard let jsonObject = json as? [String: Any] else {

            throw FetchFriendInfoError.invalidJsonObject

        }

        guard let friendName = jsonObject[Schema.name] as? String else {

            throw FetchFriendInfoError.missingName

        }

        self.name = friendName

        guard let frinedImageUrl = jsonObject[Schema.imageUrl] as? String else {

            throw FetchFriendInfoError.missingImageUrl

        }

        self.imageUrl = frinedImageUrl

    }

}
