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

    var isMicrophoneEnabled: Bool = true

    var isSpeakerEnabled: Bool = false

    var hour = 0

    var minute = 0

    var second = 0

    var secondTimer = Timer()

    var minuteTimer = Timer()

    var hourTimer = Timer()

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    let rtcManager = QBRTCClient.instance()

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentName: UILabel!

    @IBOutlet weak var connectionStatus: UILabel!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBOutlet weak var outletSpeaker: UIButton!

    @IBOutlet weak var timeLabel: UILabel!

    @IBAction func btnMicrophone(_ sender: UIButton) {

        if isMicrophoneEnabled {

            // MARK: User muted the local microphone

            isMicrophoneEnabled = false

            outletMicrophone.setImage(UIImage(named: "icon-nomic.png"), for: .normal)

            qbManager.session?.localMediaStream.audioTrack.isEnabled = false

        } else {

            // MARK: User enabled the local microphone

            isMicrophoneEnabled = true

            outletMicrophone.setImage(UIImage(named: "icon-mic.png"), for: .normal)

            qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        }

    }

    @IBAction func btnSpeaker(_ sender: UIButton) {

        if isSpeakerEnabled == false {

            // MARK: User enable the speaker

            isSpeakerEnabled = true

            outletSpeaker.setImage(UIImage(named: "icon-speaker.png"), for: .normal)

            qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.speaker

        } else {

            // MARK: User disable the speaker

            isSpeakerEnabled = false

            outletSpeaker.setImage(UIImage(named: "icon-nospeaker.png"), for: .normal)

            qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        }

    }

    @IBAction func btnHungUp(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

        UserManager.shared.endCall()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        QBRTCClient.instance().add(self)

        qbManager.session?.localMediaStream.audioTrack.isEnabled = true

        qbManager.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

        guard let opponent = UserManager.shared.opponent else { return }

        opponentName.text = opponent.name

        connectionStatus.text = "Connecting..."

        DispatchQueue.global().async {

            self.opponentImageView.sd_setImage(with: URL(string: opponent.imageUrl), placeholderImage: UIImage(named: "icon-user"))

        }
    }

}

// MARK: Timer setting
extension AudioCallViewController {

    func enableTimer() {

        secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSecond), userInfo: nil, repeats: true)

        minuteTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateMinute), userInfo: nil, repeats: true)

        hourTimer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(updateHour), userInfo: nil, repeats: true)

    }

    func updateSecond() {

        if second == 59 {

            second = 0

        } else {

            second += 1

        }

        timeLabel.text = "\(hour.addLeadingZero()) : \(minute.addLeadingZero()) : \(second.addLeadingZero())"

    }

    func updateMinute() {

        if minute == 59 {

            minute = 0

        } else {

            minute += 1

        }

        timeLabel.text = "\(hour.addLeadingZero()) : \(minute.addLeadingZero()) : \(second.addLeadingZero())"

    }

    func updateHour() {

        hour += 1

        timeLabel.text = "\(hour.addLeadingZero()) : \(minute.addLeadingZero()) : \(second.addLeadingZero())"

    }

}

extension AudioCallViewController: QBRTCClientDelegate {

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        connectionStatus.text = "Audio Connected"

        self.enableTimer()

    }
}

extension Int {

    func addLeadingZero() -> String {

        if self < 10 {

            return "0\(self)"

        } else {

            return "\(self)"

        }

    }

}
