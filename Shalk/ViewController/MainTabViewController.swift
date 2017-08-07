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

        rtcManager.add(self)

        QBRTCAudioSession.instance().initialize()

        QBRTCAudioSession.instance().initialize { (_) in }

        QBRTCAudioSession.instance().currentAudioDevice = QBRTCAudioDevice.receiver

        qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

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

                qbManager.session = session

                // MARK: 如果使用者正在配對，則前往random call的畫面，不然則表示是好友的來電，前往commingCall的畫面
                if UserManager.shared.isDiscovering == true {

                    qbManager.acceptCall()

                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                    self.performSegue(withIdentifier: "callDiscovered", sender: nil)

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

                // TODO: Error handling

                print(error.localizedDescription)

            }

        }

    }

    // MARK: 收到遠端語音
    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {

        audioTrack.isEnabled = true

    }
//    
//    // MARK: 收到遠端畫面
//    func session(_ session: QBRTCSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
//        
//        print("Gotcha Video")
//        
//        // MARK: Received remote video track
//        
//        VideoCallViewController.remoteVideoView.setVideoTrack(videoTrack)
//        
//        videoTrack.isEnabled = true
//        
//    }

    // MARK: 電話被對方接起後
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.isConnected = true

        UserManager.shared.isDiscovering = false

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    }

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        self.performSegue(withIdentifier: "callDiscovered", sender: nil)

    }

    // MARK: 連接關閉後
    func sessionDidClose(_ session: QBRTCSession) {

        qbManager.session = nil

    }

    // MARK: 電話被使用者拒絕
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        FirebaseManager().fetchChannel(withLang: UserManager.shared.discoveredLanguage)

    }

    // MARK: 電話被使用者掛斷
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        // MARK: Received a hung up signal from user.

        guard let info = userInfo else { return }

        //        print("-------------- user info -------------", userInfo)

        self.receivedEndCallwithFriendRequest(withInfo: info)

    }

}
