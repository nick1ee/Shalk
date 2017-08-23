//
//  RandomCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/30.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SCLAlertView

class RandomCallViewController: UIViewController {

    var isMicrophoneEnabled: Bool = true

    var isSpeakerEnabled: Bool = false

    let qbManager = QBManager.shared

    let rtcManager = QBRTCClient.instance()

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var outletSpeaker: UIButton!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBAction func btnSpeaker(_ sender: UIButton) {

        if isSpeakerEnabled == false {

            // MARK: User enable the speaker

            isSpeakerEnabled = true

            outletSpeaker.tintColor = UIColor.white

            outletSpeaker.layer.borderColor = UIColor.white.cgColor

            qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.speaker

        } else {

            // MARK: User disable the speaker

            isSpeakerEnabled = false

            outletSpeaker.tintColor = UIColor.darkGray

            outletSpeaker.layer.borderColor = UIColor.darkGray.cgColor

            qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        }

    }

    @IBAction func btnMicrophone(_ sender: UIButton) {

        if isMicrophoneEnabled {

            // MARK: User muted the local microphone

            isMicrophoneEnabled = false

            outletMicrophone.tintColor = UIColor.darkGray

            outletMicrophone.layer.borderColor = UIColor.darkGray.cgColor

            outletMicrophone.setImage(UIImage(named: "icon-nomic.png"), for: .normal)

            qbManager.session?.localMediaStream.audioTrack.isEnabled = false

        } else {

            // MARK: User enabled the local microphone

            isMicrophoneEnabled = true

            outletMicrophone.tintColor = UIColor.white

            outletMicrophone.layer.borderColor = UIColor.white.cgColor

            outletMicrophone.setImage(UIImage(named: "icon-mic.png"), for: .normal)

            qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        UserManager.shared.closeChannel()

        if UserManager.shared.friends.contains(where: { $0.uid == UserManager.shared.opponent?.uid }) {

        self.dismiss(animated: true, completion: nil)

        } else {

            guard let opponent = UserManager.shared.opponent else { return }

            let appearance = SCLAlertView.SCLAppearance( kTitleFont: UIFont.boldSystemFont(ofSize: 18), kTextFont: UIFont.systemFont(ofSize: 12), kButtonFont: UIFont.boldSystemFont(ofSize: 18), showCloseButton: false)

            let alert = SCLAlertView(appearance: appearance)

            alert.addButton("確定", action: {

                DispatchQueue.global().async {

                    FirebaseManager().checkFriendRequest()

                }

                self.dismiss(animated: true, completion: nil)

            })

            alert.addButton("取消", backgroundColor: UIColor.red, textColor: UIColor.white, showDurationStatus: true, action: { })

            alert.showSuccess("通話結束！", subTitle: "通話已經結束囉，是否要與\(opponent.name)成為好友呢？")

            self.dismiss(animated: true, completion: nil)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        guard let opponent = UserManager.shared.opponent else { return }

        userNameLabel.text = opponent.name.addSpacingAndCapitalized()

        if opponent.imageUrl == "null" {

            userImageView.isHidden = true

        } else {

            userImageView.isHidden = false

            userImageView.sd_setImage(with: URL(string: opponent.imageUrl), placeholderImage: UIImage(named: "icon-user"))

            userImageView.blur(withStyle: .light)

        }

    }

}
