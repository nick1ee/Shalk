//
//  ProfileManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase
import AudioToolbox
import KeychainAccess

class UserManager {

    enum RestoreError: Error {

        case missingValue(key: String)

    }

    let ref = Database.database().reference()

    static let shared = UserManager()

    private(set) var appToken: AppToken?

    var currentUser: User?

    var opponent: User?

    var roomKey: String?

    var language: String?

    var chatRooms: [ChatRoom] = []

    var chatRoomId: String = ""

    var friends: [User] = []

    var isDiscovering: Bool = false

    var discoveredLanguage = ""

    var isConnected = false

    var callType: CallType = .none

    var isPlayingCallingSound = false

    var timer: Timer?

    func logIn(withEmail email: String, withPassword pwd: String) {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().logIn(withEmail: email, withPassword: pwd)

    }

    func signUP(name: String, withEmail email: String, withPassword pwd: String) {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().signUp(name: name, withEmail: email, withPassword: pwd)

    }

    func restore(from keychain: Keychain) throws {

        typealias  Schema = AppToken.Schema

        guard let emailTokenString = try keychain.get(Schema.email) else {

            throw RestoreError.missingValue(key: Schema.email)

        }

        guard let pwdTokenString = try keychain.get(Schema.password) else {

            throw RestoreError.missingValue(key: Schema.password)
        }

        appToken = try AppToken(email: emailTokenString, password: pwdTokenString)

    }

    func registerProfile() {

        let userDict = currentUser?.toDictionary()

        guard let uid = currentUser?.uid else { return }

        FirebaseManager().registerProfile(uid: uid, userDict: userDict!)

    }

    func logOut() {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().logOut()

    }

    func startAudioCall() {

        self.isPlayingCallingSound = true

        self.playCallingSound()

        QBManager.shared.startAudioCall()
    }

    func startVideoCall() {

        self.isPlayingCallingSound = true

        self.playCallingSound()

        QBManager.shared.startVideoCall()

    }

    func endCall() {

        QBManager.shared.handUpCall()

    }

    func closeChannel() {

        QBManager.shared.handUpCall()

        FirebaseManager().closeChannel()

    }

    func fetchChatRoomList() {

        FirebaseManager().fetchChatRoomList()

    }

    func startChat(withVC: UIViewController, to opponent: User) {

        let result = chatRooms.filter({ $0.user1Id == opponent.uid || $0.user2Id == opponent.uid })

        self.opponent = opponent

        if result.count == 0 {

            FirebaseManager().createChatRoom(to: opponent)

            withVC.performSegue(withIdentifier: "startChat", sender: nil)

        } else {

            self.chatRoomId = result[0].roomId

            withVC.performSegue(withIdentifier: "startChat", sender: nil)

        }

    }

    @objc func playCallingSound() {

        if isPlayingCallingSound == true {

            timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)

        } else {

            timer?.invalidate()
            timer = nil
        }

    }

    @objc func playSound() {

         AudioServicesPlaySystemSound(1151)

    }

}
