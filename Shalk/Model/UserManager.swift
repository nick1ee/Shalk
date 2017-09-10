//
//  ProfileManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - UserManager
import UIKit
import Foundation
import AudioToolbox

class UserManager {

    static let shared = UserManager()

    var currentUser: User?

    var opponent: User?

    var roomKey: String?

    var language: String?

    var chatRooms: [ChatRoom] = [] {

        didSet {

            if chatRooms.count == 0 {

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RoomChange"), object: nil)

            }

        }

    }

    var chatRoomId: String = ""

    var friends: [User] = [] {

        didSet {

            if friends.count == 0 {

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FriendChange"), object: nil)

            }

        }

    }

    var isDiscovering: Bool = false

    var isConnected = false

    var callType: CallType = .none

    var isPlayingCallingSound = false

    var playingSoundTimer: Timer?

    func logIn(withEmail email: String, withPassword pwd: String) {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().logIn(withEmail: email, withPassword: pwd)

    }

    func signUp(name: String, withEmail email: String, withPassword pwd: String) {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().signUp(name: name, withEmail: email, withPassword: pwd)

    }

    func registerProfile() {

        if let uid = currentUser?.uid, let userDict = currentUser?.toDictionary() {

            FirebaseManager().registerProfile(uid: uid, userDict: userDict)

        }

    }

    func logOut() {

        UIApplication.shared.beginIgnoringInteractionEvents()

        FirebaseManager().logOut()

    }

    func startAudioCall() {

        isPlayingCallingSound = true

        playingSound()

        QBManager.shared.startAudioCall()
    }

    func startVideoCall() {

        isPlayingCallingSound = true

        playingSound()

        QBManager.shared.startVideoCall()

    }

    func closeChannel() {

        QBManager.shared.handUpCall(nil)

        FirebaseManager().closeChannel()

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

    func playingSound() {

        playingSoundTimer = Timer()

        playingSoundTimer?.start(
            DispatchTime.now(),
            interval: 4,
            repeats: true
        ) {

            AudioServicesPlaySystemSound(1151)

        }

    }

    func stopPlayingSound() {

        playingSoundTimer?.cancel()

    }

}
