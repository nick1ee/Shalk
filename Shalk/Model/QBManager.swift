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

    var opponent: Opponent?

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

            ProfileManager.shared.qbID = Int(okUser.id)

        }) { (response) in

            // TODO: User failed to sign up a new account.

            let error = response.error?.error

            print(error?.localizedDescription ?? "No error data")

        }

    }

    func startAudioCall() {

        guard
            let name = opponent?.name,
            let image = opponent?.imageURL,
            let opponentID = [opponent?.quickbloxID] as? [NSNumber] else { return }

        session = rtcManager.createNewSession(withOpponents: opponentID, with: .audio)

        let userInfo = ["name": name, "image": image]

        session?.startCall(userInfo)

    }

    func rejectCall() {

    }

    func acceptCall() {

        self.session?.acceptCall(nil)

    }

    func hangUpCall() {

        self.session?.hangUp(nil)

        self.opponent = nil

    }

}
