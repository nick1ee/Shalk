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

    var videoCapture: QBRTCCameraCapture?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.selectedIndex = 2

        rtcManager.add(self)

        QBRTCAudioSession.instance().initialize()

        self.tabBarController?.tabBar.backgroundColor = UIColor.clear

        self.tabBarController?.tabBar.tintColor = UIColor.init(red: 62/255, green: 48/255, blue: 76/255, alpha: 1)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "comingCall" {

            let comingCallVC = segue.destination as? ComingCallViewController

            comingCallVC?.callTypeString = callType

        }

    }

}

extension MainTabViewController: QBRTCClientDelegate {

    // MARK: 收到新的連線請求
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {

        if qbManager.session != nil {

            // MARK: This device is on call

            session.rejectCall(nil)

        } else {

            // MARK: Accepted the call

            do {

                let user = try User.init(json: userInfo!)

                UserManager.shared.opponent = user

                qbManager.session = session

                // MARK: 如果使用者正在配對，則前往random call的畫面，不然則表示是好友的來電，前往commingCall的畫面
                if UserManager.shared.isDiscovering == true {

                    qbManager.acceptCall()

                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                    self.performSegue(withIdentifier: "callDiscovered", sender: nil)

                    UserManager.shared.isDiscovering = false

                } else {

                    switch session.conferenceType {

                    case .audio:

                        callType = "Audio Call"

                        self.performSegue(withIdentifier: "comingCall", sender: nil)

                    case .video:

                        callType = "Video Call"

                        self.performSegue(withIdentifier: "comingCall", sender: nil)

                    }

                }

            } catch let error {

                // MARK: Failed to init a coming call.

                UIAlertController(error: error).show()

            }

        }

    }

    // MARK: 收到遠端語音
    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {

        audioTrack.isEnabled = true

    }

    // MARK: 電話被對方接起後
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.isPlayingCallingSound = false

        UserManager.shared.playCallingSound()

        UserManager.shared.isConnected = true

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        if UserManager.shared.isDiscovering == true {

            self.performSegue(withIdentifier: "callDiscovered", sender: nil)

            UserManager.shared.isDiscovering = false

        }

    }

    // MARK: 連接關閉後
    func sessionDidClose(_ session: QBRTCSession) {

        qbManager.session = nil

    }

    // MARK: 電話被使用者拒絕
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.isPlayingCallingSound = false

        UserManager.shared.playCallingSound()

        if UserManager.shared.isDiscovering == true {

            FirebaseManager().fetchChannel(withLanguage: UserManager.shared.language!)

        }

    }

    // MARK: 電話被使用者掛斷
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.isPlayingCallingSound = false

        UserManager.shared.playCallingSound()

        // MARK: Received a hung up signal from user.

        let userString = String(describing: userID)

        let friend = UserManager.shared.friends.filter { $0.quickbloxId == userString }

        if friend.count == 0 {

            // MARK: 非好友
            self.receivedEndCallwithFriendRequest()

            return

        }

        // MARK: 確定為好友

        self.dismiss(animated: true, completion: nil)

    }

    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {

        UserManager.shared.isPlayingCallingSound = false

        UserManager.shared.playCallingSound()

        self.presentedViewController?.pushNoRespondMessage()

    }

}
