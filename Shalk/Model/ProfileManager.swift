//
//  ProfileManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation

class ProfileManager {

    var name: String = ""

    var email: String = ""

    static var shared: ProfileManager?

    static func sharedInstance() -> ProfileManager {

        if shared == nil {

            shared = ProfileManager()

        }

        return shared!

    }

}
