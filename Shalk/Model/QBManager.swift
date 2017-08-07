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

                    UserManager.shared.fetchUserData()

                    UserDefaults.standard.set(email, forKey: "email")

                    UserDefaults.standard.set(password, forKey: "password")

                    UserDefaults.standard.synchronize()

                    let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabVC")

                    AppDelegate.shared.window?.rootViewController = mainTabVC

                } else {

                    // MARK: Failed to connect chat service.

                }

            })

        }) { (response) in

            // MARK: User failed to login.

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            let error = response.error?.error

            UIAlertController(error: error!).show()

        }

        SVProgressHUD.show(withStatus: "Connecting to chat service.")

    }

    func logOut() {

        QBRequest.logOut(successBlock: { (response) in

            QBChat.instance().disconnect(completionBlock: { (error) in

                if error == nil {

                    // MARK: User Log out successfully.

                    SVProgressHUD.dismiss()

                    UIApplication.shared.endIgnoringInteractionEvents()

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

            SVProgressHUD.show(withStatus: "Sign up successfully, start to log in.")

            let qbIdToString = String(qbUser.id)

            let okUser = User.init(name: name, uid: uid, email: email, quickbloxId: qbIdToString)

            UserManager.shared.currentUser = okUser

            UserManager.shared.registerProfile()

            FirebaseManager().logIn(withEmail: email, withPassword: password)

        }) { (response) in

            // MARK: User failed to sign up a new account.

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            let error = response.error?.error

            UIAlertController(error: error!).show()

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

    func captureVideo() {

        let videoFormat = QBRTCVideoFormat.init()

        videoFormat.frameRate = 30

        videoFormat.pixelFormat = QBRTCPixelFormat.format420f

        videoFormat.width = 640

        videoFormat.height = 480

        self.videoCapture = QBRTCCameraCapture.init(videoFormat: videoFormat, position: AVCaptureDevicePosition.front)

        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture

        //        self.videoCapture!.previewLayer.frame = self.localVideoView.bounds

        self.videoCapture!.startSession()

        //        self.localVideoView.layer.insertSublayer(videoCapture!.previewLayer, at: 0)

    }

    func startVideoCall() {

        userManager.isConnected = true

        guard
            let qbID = userManager.opponent?.quickbloxId,
            let qbIDInteger = Int(qbID),
            let opponentID = [qbIDInteger] as? [NSNumber] else { return }

        let userInfo = userManager.currentUser?.toDictionary()

        session = rtcManager.createNewSession(withOpponents: opponentID, with: .video)

        captureVideo()

        session?.startCall(userInfo)

    }

    func rejectCall() {

    }

    func acceptCall() {

        self.session?.acceptCall(nil)

        userManager.isConnected = true

    }

    func handUpCall() {

        self.session?.hangUp(nil)

        userManager.isConnected = false

    }

    func leaveChannel() {

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
