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

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    let rtcManager = QBRTCClient.instance()

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBOutlet weak var outletSpeaker: UIButton!

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

        QBManager.shared.hangUpCall()

        UserManager.shared.isConnected = false

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rtcManager.add(self)

        QBManager.shared.audioManager.initialize()

        QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver
    }

}

extension AudioCallViewController: QBRTCClientDelegate {

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

}
