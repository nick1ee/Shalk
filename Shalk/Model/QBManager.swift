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

    func signUp(withEmail email: String, withPassword password: String) {

        let signUpUser = QBUUser()

        signUpUser.email = email

        signUpUser.password = password

        QBRequest.signUp(signUpUser, successBlock: {(response, user) in

            // MARK: User signed up a new account on Quickblox successfully.

            guard let okUser = user else { return }

            UserManager.shared.qbID = Int(okUser.id)

        }) { (response) in

            // TODO: User failed to sign up a new account.

            let error = response.error?.error

            print(error?.localizedDescription ?? "No error data")

        }

    }

    func startAudioCall() {

        userManager.isConnected = true

        guard
            let uid = userManager.opponent?.uid,
            let name = userManager.opponent?.name,
            let image = userManager.opponent?.imageURL,
            let qbID = userManager.opponent?.quickbloxID else { return }
        
        guard let opponentID = [Int(qbID)] as? [NSNumber] else { return }

        session = rtcManager.createNewSession(withOpponents: opponentID, with: .audio)

        let userInfo = ["uid": uid, "name": name, "imageURL": image, "quickbloxID": qbID]

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

        userManager.opponent = nil

    }

}
