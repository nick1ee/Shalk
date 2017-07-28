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
