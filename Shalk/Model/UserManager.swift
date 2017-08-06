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

                currentUser?.quickbloxId = String(qbID)

                let userDict = currentUser?.toDictionary()

                guard let uid = currentUser?.uid else { return }

                self.ref.child("users").child(uid).setValue(userDict)

            }

        }

    }

    func fetchUserData() {

        guard let userID = Auth.auth().currentUser?.uid else { return }

        FirebaseManager().fetchUserProfile(withUid: userID, type: .myself)

    }

    func joinChannel() {

        QBManager.shared.startAudioCall()

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

    func fetchChatHistroy() {

    }

}
