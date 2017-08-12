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
import AudioToolbox

class AudioCallViewController: UIViewController {

    var isMicrophoneEnabled: Bool = true

    var isSpeakerEnabled: Bool = false

    var hour = 0

    var minute = 0

    var second = 0

    var secondTimer: DispatchSourceTimer?

    var minuteTimer: DispatchSourceTimer?

    var hourTimer: DispatchSourceTimer?

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.stopTimer()

    }

}

// MARK: Timer setting
extension AudioCallViewController {

    func configTimer() {

        let timerQueue = DispatchQueue(label: "timer", attributes: .concurrent)

        secondTimer?.cancel()

        secondTimer = DispatchSource.makeTimerSource(queue: timerQueue)

        secondTimer?.scheduleRepeating(deadline: .now(), interval: 1.0, leeway: .microseconds(10))

        secondTimer?.setEventHandler {

            if self.second == 59 {

                self.second = 0

            } else {

                self.second += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        }

        secondTimer?.resume()

        minuteTimer?.cancel()

        minuteTimer = DispatchSource.makeTimerSource(queue: timerQueue)

        minuteTimer?.scheduleRepeating(deadline: .now(), interval: 60.0, leeway: .microseconds(10))

        minuteTimer?.setEventHandler {

            if self.minute == 59 {

                self.minute = 0

            } else {

                self.minute += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        }

        minuteTimer?.resume()

        hourTimer?.cancel()

        hourTimer = DispatchSource.makeTimerSource(queue: timerQueue)

        hourTimer?.scheduleRepeating(deadline: .now(), interval: 3600.0, leeway: .microseconds(10))

        hourTimer?.setEventHandler {

            self.hour += 1

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        }
    }

    func stopTimer() {

        secondTimer?.cancel()

        secondTimer = nil

        minuteTimer?.cancel()

        minuteTimer = nil

        hourTimer?.cancel()

        hourTimer = nil

        second = 0

        minute = 0

        hour = 0

    }
}

extension AudioCallViewController: QBRTCClientDelegate {

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        connectionStatus.text = "Audio Connected"

        self.configTimer()

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
