//
//  ProfileManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

class ProfileManager {

    let ref = Database.database().reference()

    static let shared = ProfileManager()

    var currentUser: User?

    var qbID: Int = 0 {

        didSet {

            if qbID != 0 {

                currentUser?.quickbloxID = qbID

                guard let userDict = currentUser?.description else { return }

                guard let uid = currentUser?.uid else { return }

                self.ref.child("users").child(uid).setValue(userDict)

            }

        }

    }

}
