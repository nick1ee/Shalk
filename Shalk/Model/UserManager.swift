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

    var currentUser: User? {

        didSet {

            if self.isFirebaseLogin == false && self.isQuickbloxLogin == false {

                let loginVC = UIStoryboard(name: "Main",

                                           bundle: nil).instantiateViewController(withIdentifier: "loginVC")

                AppDelegate.shared.window?.rootViewController = loginVC

            }

        }

    }

    var opponent: User?

    var roomKey: String?

    var language: String?

    var chatRooms: [ChatRoom] = []

    var chatRoomId: String = ""

    var isSendingFriendRequest: Bool?

    var friendsWithEnglish: [User] = []

    var friendsWithChinese: [User] = []

    var friendsWithJapanese: [User] = []

    var friendsWithKorean: [User] = []

    var isFirebaseLogin: Bool = false

    var isQuickbloxLogin: Bool = false

    var isDiscovering: Bool = false

    var discoveredLanguage = ""

    var isConnected = false

    var qbID: Int = 0 {

        didSet {

            if qbID != 0 {

                currentUser?.quickbloxId = String(qbID)

                let userDict = currentUser?.toDictionary()

                guard let uid = currentUser?.uid else { return }

                self.ref.child("users").child(uid).setValue(userDict)

            }

        }

    }

    func logOut() {

        FirebaseManager().logOut()

    }

    func fetchUserData() {

        guard let userID = Auth.auth().currentUser?.uid else { return }

        FirebaseManager().fetchUserProfile(withUid: userID, type: .myself, call: CallType.audio)

    }

    func startAudioCall() {

        QBManager.shared.startAudioCall()
    }

    func startVideoCall() {

        QBManager.shared.startVideoCall()

    }

    func closeChannel() {

        FirebaseManager().closeChannel(withRoomKey: self.roomKey!, withLang: self.language!)

    }

    func fetchChatRoomList() {

        FirebaseManager().fetchChatRoomList()

    }

    func startChat(withVC: UIViewController, to opponent: User) {

        let result = chatRooms.filter({ $0.user1Id == opponent.uid || $0.user2Id == opponent.uid })

        if result.count == 0 {

            FirebaseManager().createChatRoom(to: opponent)

            withVC.performSegue(withIdentifier: "startChat", sender: nil)

        } else {

            self.chatRoomId = result[0].roomId

            withVC.performSegue(withIdentifier: "startChat", sender: nil)

        }

    }

}
