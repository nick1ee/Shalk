//
//  AudioCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class AudioCallViewController: UIViewController {

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    let rtcManager = QBRTCClient.instance()

    @IBAction func btnEndCall(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rtcManager.add(self)

        QBManager.shared.audioManager.initialize()

        QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver
    }

}

extension AudioCallViewController: QBRTCClientDelegate {

    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {

        // MARK: received other's call

        if qbManager.session != nil {

            let userInfo = ["key": "value"]

            session.rejectCall(userInfo)

        } else {

            do {

                qbManager.session = session

                userManager.opponent = try User.init(json: userInfo!)

                qbManager.acceptCall()

                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                self.performSegue(withIdentifier: "audioCall", sender: nil)

            } catch let error {

                // TODO: Error handling

                print("=======================================", error.localizedDescription)

            }
        }
    }

    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {

        // MARK: Received the remote audio track.

        audioTrack.isEnabled = true

    }

    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: The callee accepted the call.

        userManager.isConnected = true

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    }

    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        // MARK: connected successfully, and get started to chat.

    }

    func sessionDidClose(_ session: QBRTCSession) {

        // MARK: The session had been closed.

        qbManager.session = nil

    }

    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: If user reject the call, do something here.

    }

    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: Received a hung up signal from user.

        guard let info = userInfo else { return }

        //        print("-------------- user info -------------", userInfo)

        self.receivedEndCallwithFriendRequest(withInfo: info)

    }

}
