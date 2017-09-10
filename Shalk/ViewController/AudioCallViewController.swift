//
//  AudioCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - AudioCallViewController

import UIKit
import Quickblox
import QuickbloxWebRTC
import AudioToolbox

class AudioCallViewController: UIViewController {

    // MARK: Property

    var hour = 0

    var minute = 0

    var second = 0

    let secondTimer: Timer = Timer()

    let minuteTimer: Timer = Timer()

    let hourTimer: Timer = Timer()

    var isMicrophoneEnabled: Bool = true

    var isSpeakerEnabled: Bool = false

    let rtcManager = QBRTCClient.instance()

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentName: UILabel!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBOutlet weak var outletSpeaker: UIButton!

    @IBOutlet weak var timeLabel: UILabel!

    @IBAction func btnMicrophone(_ sender: UIButton) {

        if isMicrophoneEnabled {

            // MARK: User muted the local microphone

            isMicrophoneEnabled = false

            outletMicrophone.tintColor = UIColor.darkGray

            outletMicrophone.layer.borderColor = UIColor.darkGray.cgColor

            outletMicrophone.setImage(
                UIImage(named: "icon-nomic.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.audioTrack.isEnabled = false

        } else {

            // MARK: User enabled the local microphone

            isMicrophoneEnabled = true

            outletMicrophone.tintColor = UIColor.white

            outletMicrophone.layer.borderColor = UIColor.white.cgColor

            outletMicrophone.setImage(
                UIImage(named: "icon-mic.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.audioTrack.isEnabled = true

        }

    }

    @IBAction func btnSpeaker(_ sender: UIButton) {

        if isSpeakerEnabled == false {

            // MARK: User enable the speaker

            isSpeakerEnabled = true

            outletSpeaker.tintColor = UIColor.white

            outletSpeaker.layer.borderColor = UIColor.white.cgColor

            QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.speaker

        } else {

            // MARK: User disable the speaker

            isSpeakerEnabled = false

            outletSpeaker.tintColor = UIColor.darkGray

            outletSpeaker.layer.borderColor = UIColor.darkGray.cgColor

            QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        }

    }

    @IBAction func btnHungUp(_ sender: UIButton) {

        UserManager.shared.isConnected = false

        let duration = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        let roomId = UserManager.shared.chatRoomId

        let callinfo = [
            "callType": CallType.audio.rawValue,
            "duration": duration,
            "roomId": roomId
        ]

        guard
            let hostQbId = QBManager.shared.session?.initiatorID as? Int,
            let user = UserManager.shared.currentUser
            else {

                return

        }

        let hostQbString = String(describing: hostQbId)

        if user.quickbloxId == hostQbString {

            DispatchQueue.global().async {

                FirebaseManager().sendCallRecord(
                    .audio,
                    duration: duration,
                    roomId: roomId
                )

            }

        }

        QBManager.shared.handUpCall(callinfo)

        self.dismiss(
            animated: true,
            completion: nil
        )

    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        QBRTCClient.instance().add(self)

        QBManager.shared.session?.localMediaStream.audioTrack.isEnabled = true

        QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        if let opponent = UserManager.shared.opponent {

            opponentName.text = opponent.name.addSpacingAndCapitalized()

            self.opponentImageView.sd_setImage(
                with: URL(string: opponent.imageUrl),
                placeholderImage: UIImage(named: "icon-user")
            )

        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.stopTimer()

    }

}

// MARK: Timer Configuration

extension AudioCallViewController {

    func configTimer() {

        secondTimer.start(DispatchTime.now(), interval: 1, repeats: true) {

            if self.second == 59 {

                self.second = 0

            } else {

                self.second += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"
        }

        minuteTimer.start(DispatchTime.now() + 60.0, interval: 60, repeats: true) {

            if self.minute == 59 {

                self.minute = 0

            } else {

                self.minute += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        }

        hourTimer.start(DispatchTime.now() + 3600.0, interval: 3600, repeats: true) {

            self.hour += 1

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        }

    }

    func stopTimer() {

        secondTimer.cancel()

        minuteTimer.cancel()

        hourTimer.cancel()

        second = 0

        minute = 0

        hour = 0

    }
}

// MARK: QBRTCClientDelegate

extension AudioCallViewController: QBRTCClientDelegate {

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        self.configTimer()

    }

}
