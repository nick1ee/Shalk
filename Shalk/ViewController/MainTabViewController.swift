//
//  MainTabViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/7.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class MainTabViewController: UITabBarController {

    var opponentName = ""

    var callType = ""

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    let rtcManager = QBRTCClient.instance()

    override func viewDidLoad() {
        super.viewDidLoad()

        rtcManager.add(self)

        QBRTCAudioSession.instance().initialize()

        QBRTCAudioSession.instance().initialize { (_) in }

        QBRTCAudioSession.instance().currentAudioDevice = QBRTCAudioDevice.receiver

        qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

    }

}

extension MainTabViewController: QBRTCClientDelegate {

    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {

        print("get in here~~~~~~~~~~~~~~~~~~~~~~")

        if qbManager.session != nil {

            // MARK: This device is on call

            let userInfo = ["key": "value"]

            session.rejectCall(userInfo)

        } else {

            // MARK: Accepted the call

            do {

                let user = try User.init(json: userInfo!)

                UserManager.shared.opponent = user

            } catch let error {

                // TODO: Error handling

                print(error.localizedDescription)

            }

            switch session.conferenceType {

            case .audio:

                callType = "Audio Call"

                self.performSegue(withIdentifier: "comingCall", sender: nil)

            case .video:

                callType = "Video Call"

                self.performSegue(withIdentifier: "comingCall", sender: nil)

            }

        }

    }

    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: The opponent has accepted the call.

        print("The call had been accepted by \(userID)")

    }

    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: The call had been hung up by the opponent

        if session.initiatorID.isEqual(to: userID) {

            session.hangUp(userInfo)

        }
    }

}
