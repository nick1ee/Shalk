//
//  QBManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC

class QBManager {

    static let shared = QBManager()

    let rtcManager = QBRTCClient.instance()

    let audioManager = QBRTCAudioSession.instance()

    let userManager = UserManager.shared

//    var opponent: Opponent?

    var session: QBRTCSession?

    func logIn(withEmail email: String, withPassword password: String) {

        QBRequest.logIn(withUserEmail: email, password: password, successBlock: { (response, user) in

            // MARK: User logged in with Quickblox successfully.

            guard let okUser = user else { return }

            self.userManager.isQuickbloxLogin = true

            okUser.password = password

            QBChat.instance().connect(with: okUser, completion: { (error) in

                if error == nil {

                    print("user login quickblox successfully")

                }

            })

        }) { (response) in

            // TODO: User failed to loggin.

            let error = response.error?.error

            print(error?.localizedDescription ?? "No error data")

        }

    }

    func logOut() {

        QBRequest.logOut(successBlock: { (response) in

            // MARK: User Log out successfully.
            self.userManager.isQuickbloxLogin = false

            UserManager.shared.currentUser = nil

        }) { (response) in

            // TODO: Error handling

            let error = response.error?.error
            print(error?.localizedDescription)

        }

    }

    func signUp(withEmail email: String, withPassword password: String) {

        let signUpUser = QBUUser()

        signUpUser.email = email

        signUpUser.password = password

        print("~~~~~~~~~~~~~~~~~~~~~~~~", signUpUser)

        QBRequest.signUp(signUpUser, successBlock: {(response, user) in

            // MARK: User signed up a new account on Quickblox successfully.

            guard let okUser = user else { return }

            self.userManager.qbID = Int(okUser.id)

        }) { (response) in

            // TODO: User failed to sign up a new account.

            let error = response.error?.error

            print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", error?.localizedDescription ?? "No error data")

        }

    }

    func startAudioCall() {

        userManager.isConnected = true

        guard
            let qbID = userManager.opponent?.quickbloxId,
            let qbIDInteger = Int(qbID),
            let opponentID = [qbIDInteger] as? [NSNumber] else { return }

        let userInfo = userManager.currentUser?.toDictionary()

        session = rtcManager.createNewSession(withOpponents: opponentID, with: .audio)

        session?.startCall(userInfo)

    }

    func startVideoCall() {

        userManager.isConnected = true

        guard
            let qbID = userManager.opponent?.quickbloxId,
            let qbIDInteger = Int(qbID),
            let opponentID = [qbIDInteger] as? [NSNumber] else { return }

        let userInfo = userManager.currentUser?.toDictionary()

        session = rtcManager.createNewSession(withOpponents: opponentID, with: .video)

        session?.startCall(userInfo)

    }

    func rejectCall() {

    }

    func acceptCall() {

        self.session?.acceptCall(nil)

        userManager.isConnected = true

    }

    func hangUpCall() {

        var info: [String: String] = [:]

        if userManager.isSendingFriendRequest == true {

            info = ["sendRequest": "yes"]

        } else {

            info = ["sendRequest": "no"]

        }

        self.session?.hangUp(info)

        userManager.closeChannel()

        userManager.isConnected = false

    }

}
