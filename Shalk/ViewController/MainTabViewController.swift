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
import Crashlytics
import SCLAlertView

class MainTabViewController: UITabBarController {

    var opponentName = ""

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    let rtcManager = QBRTCClient.instance()

    var videoCapture: QBRTCCameraCapture?

    override func viewDidLoad() {
        super.viewDidLoad()

        rtcManager.add(self)

        QBRTCAudioSession.instance().initialize()

        self.tabBarController?.tabBar.backgroundColor = UIColor.clear

        self.tabBarController?.tabBar.tintColor = UIColor.init(red: 62/255, green: 48/255, blue: 76/255, alpha: 1)

        FirebaseManager().fetchChatRoomList()

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

                let opponent = try User.init(json: userInfo!)

                UserManager.shared.opponent = opponent

                qbManager.session = session

                // MARK: 如果使用者正在配對，則前往random call的畫面，不然則表示是好友的來電，前往commingCall的畫面
                if UserManager.shared.isDiscovering == true {

                    qbManager.acceptCall()

                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                    self.performSegue(withIdentifier: "callDiscovered", sender: nil)

                    UserManager.shared.isDiscovering = false

                } else {

                    let chatRoom = UserManager.shared.chatRooms.filter { $0.user1Id == opponent.uid || $0.user2Id == opponent.uid }

                    UserManager.shared.chatRoomId = chatRoom[0].roomId

                    switch session.conferenceType {

                    case .audio:

                        let comingCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComingCallVC") as? ComingCallViewController

                        comingCallVC?.callType = CallType.audio

                        AppDelegate.shared.window?.rootViewController?.present(comingCallVC!, animated: true, completion: nil)

                    case .video:

                        let comingCallVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ComingCallVC") as? ComingCallViewController

                        comingCallVC?.callType = CallType.video

                        AppDelegate.shared.window?.rootViewController?.present(comingCallVC!, animated: true, completion: nil)

                    }

                }

            } catch let error {
                // MARK: Failed to init a coming call.

                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["info": "Init_ComingCall_Error"])

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

        UserManager.shared.stopPlayingSound()

        UserManager.shared.isConnected = true

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        if UserManager.shared.isDiscovering == true {

            self.performSegue(withIdentifier: "callDiscovered", sender: nil)

            UserManager.shared.isDiscovering = false

        }

    }

    // MARK: 連接關閉後
    func sessionDidClose(_ session: QBRTCSession) {

        QBManager.shared.session = nil

        guard let user = UserManager.shared.currentUser else { return }

        let hostId = String(describing: session.initiatorID)

        if hostId == user.quickbloxId {

        }

    }

    // MARK: 電話被使用者拒絕
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.stopPlayingSound()

        guard let opponent = UserManager.shared.opponent else { return }

        let alert = UIAlertController.init(title: NSLocalizedString("Oops", comment: ""), message: "\(opponent.name)" + NSLocalizedString("Reject_Call", comment: ""), preferredStyle: .alert)

        alert.addAction(title: "OK", style: .default, isEnabled: true) { (_) in

            self.dismiss(animated: true, completion: nil)

        }

        self.presentedViewController?.present(alert, animated: true, completion: nil)

        if UserManager.shared.isDiscovering == true {

            FirebaseManager().fetchChannel()

        }

    }

    // MARK: 電話被使用者掛斷
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {

        UserManager.shared.stopPlayingSound()

        // MARK: Received a hung up signal from user.

        let userString = String(describing: userID)

        if UserManager.shared.friends.contains(where: { $0.quickbloxId == userString }) {

            // MARK: 確定為好友

            self.dismiss(animated: true, completion: nil)

            if UserManager.shared.isConnected == true {

                guard
                    let hostQbId = session.initiatorID as? Int,
                    let user = UserManager.shared.currentUser
                    else {
                        
                        return
                
                }

                let hostQbString = String(describing: hostQbId)

                if user.quickbloxId == hostQbString {

                    guard
                        let callType = userInfo?["callType"],
                        let duration = userInfo?["duration"],
                        let chatRoomId = userInfo?["roomId"]
                        else {
                            
                            return
                    
                    }

                    FirebaseManager().sendCallRecord(CallType(rawValue: callType)!, duration: duration, roomId: chatRoomId)

                }

            }

        } else {

            // MARK: Not friends, init a friend request.
            guard let opponent = UserManager.shared.opponent else { return }

            let appearance = SCLAlertView.SCLAppearance( kTitleFont: UIFont.boldSystemFont(ofSize: 18), kTextFont: UIFont.systemFont(ofSize: 12), kButtonFont: UIFont.boldSystemFont(ofSize: 18), showCloseButton: false)

            let alert = SCLAlertView(appearance: appearance)

            alert.addButton("確定", action: {

                DispatchQueue.global().async {

                    FirebaseManager().checkFriendRequest()

                }

            })

            alert.addButton("取消", backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: true, action: { })

            alert.showSuccess("通話結束！", subTitle: "通話已經結束囉，是否要與\(opponent.name)成為好友呢？")

            self.presentedViewController?.dismiss(animated: true, completion: nil)

        }

    }

    // MARK: 使用者沒有回應
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {

        UserManager.shared.stopPlayingSound()

        guard let opponent = UserManager.shared.opponent else { return }

        if String(describing: session.opponentsIDs[0]) == opponent.quickbloxId {

            let alert = UIAlertController.init(title: NSLocalizedString("Oops", comment: ""), message: "\(opponent.name)" + NSLocalizedString("No_Answer", comment: ""), preferredStyle: .alert)

            alert.addAction(title: "OK", style: .default, isEnabled: true) { (_) in

                self.dismiss(animated: true, completion: nil)

            }

            self.presentedViewController?.present(alert, animated: true, completion: nil)

        } else {

            self.dismiss(animated: true, completion: nil)

        }

    }

}
