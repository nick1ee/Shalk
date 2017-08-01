//
//  ProfileManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

class UserManager {

    let ref = Database.database().reference()

    static let shared = UserManager()

    var currentUser: User?

    var opponent: Opponent?

    var roomKey: String?

    var language: String?

    var isSendingFriendRequest: Bool?

    var isConnected = false {

        didSet {

            if isConnected == true {

                FirebaseManager().updateChannel(withRoomKey: self.roomKey!, withLang: language!)

            }

        }

    }

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

    func fetchUserData() {

        FirebaseManager().fetchUserProfile()

    }

    func joinChannel() {

        QBManager.shared.startAudioCall()

    }

    func closeChannel() {

        FirebaseManager().closeChannel(withRoomKey: self.roomKey!, withLang: self.language!)

    }

}
