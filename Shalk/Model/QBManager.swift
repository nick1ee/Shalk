//
//  QBManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

class QBManager {

    static let shared = QBManager()

    let rtcManager = QBRTCClient.instance()

    let audioManager = QBRTCAudioSession.instance()

    let userManager = UserManager.shared

    var videoCapture: QBRTCCameraCapture?

    var session: QBRTCSession?

    func logIn(withEmail email: String, withPassword password: String) {

        QBRequest.logIn(withUserEmail: email, password: password, successBlock: { (response, user) in

            // MARK: User logged in with Quickblox successfully.

            guard let okUser = user else { return }

            okUser.password = password

            QBChat.instance().connect(with: okUser, completion: { (error) in

                if error == nil {

                    // MARK: User sign in with Quickblox successfully.

                    SVProgressHUD.dismiss()

                    UIApplication.shared.endIgnoringInteractionEvents()

                    //swiftlint:disable force_cast
                    let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController

                    mainTabVC.selectedIndex = 2

                    AppDelegate.shared.window?.rootViewController = mainTabVC

                } else {

                    // MARK: Failed to connect chat service.

                    SVProgressHUD.dismiss()

                    UIApplication.shared.endIgnoringInteractionEvents()

                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Login_ChatService_Error", comment: ""), preferredStyle: .alert)

                    alert.addAction(title: "OK")

                    alert.show()

                }

            })

        }) { (response) in

            // MARK: User failed to login, suspect to

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            let error = response.error?.error

            UIAlertController(error: error!).show()

        }

        SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Connecting_ChatService", comment: ""))

    }

    func logOut() {

        QBRequest.logOut(successBlock: { (response) in

            QBChat.instance().disconnect(completionBlock: { (error) in

                if error == nil {

                    // MARK: User Log out successfully.

                    SVProgressHUD.dismiss()

                    UIApplication.shared.endIgnoringInteractionEvents()

                    UserManager.shared.deleteToken()

                    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")

                    AppDelegate.shared.window?.rootViewController = loginVC

                    UserManager.shared.currentUser = nil

                } else {

                    // MARK: User failed to log out with chat service.

                    SVProgressHUD.dismiss()

                    UIApplication.shared.endIgnoringInteractionEvents()

                    UIAlertController(error: error!).show()

                }

            })

        }) { (response) in

            // MARK: User failed to log out with Quickblox

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            let error = response.error?.error

            UIAlertController(error: error!).show()

        }

    }

    func signUp(name: String, uid: String, withEmail email: String, withPassword password: String) {

        // MARK: Start to sign up on Quickblox

        let signUpUser = QBUUser()

        signUpUser.email = email

        signUpUser.password = password

        QBRequest.signUp(signUpUser, successBlock: {(response, user) in

            // MARK: User signed up a new account on Quickblox successfully.

            guard let qbUser = user else { return }

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Register_Success", comment: ""))

            let qbIdToString = String(qbUser.id)

            let okUser = User.init(name: name, uid: uid, email: email, quickbloxId: qbIdToString)

            UserManager.shared.currentUser = okUser

            UserManager.shared.registerProfile()

            FirebaseManager().logIn(withEmail: email, withPassword: password)

        }) { (response) in

            // MARK: User failed to sign up a new account.

            UIApplication.shared.endIgnoringInteractionEvents()

            let error = response.error?.error

            UIAlertController(error: error!).show()

        }

    }

}

// MARK: Call functions
extension QBManager {

    func startAudioCall() {

        FirebaseManager().logEvent("start_audio_call")

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

        FirebaseManager().logEvent("start_video_call")

        userManager.isConnected = true

        let userInfo = UserManager.shared.currentUser?.toDictionary()

        session?.startCall(userInfo)

    }

    func acceptCall() {

        self.session?.acceptCall(nil)

        userManager.isConnected = true

    }

    func handUpCall(_ userInfo: [String: String]?) {

        UserManager.shared.stopPlayingSound()

        self.session?.hangUp(userInfo)

        userManager.isConnected = false

        self.session = nil

    }

    func rejectCall(_ userInfo: [String: String]?) {

        self.session?.rejectCall(nil)

        self.session = nil

    }

}
