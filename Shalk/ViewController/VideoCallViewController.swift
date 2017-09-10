//
//  VideoCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - VideoCallViewController

import UIKit
import Quickblox
import QuickbloxWebRTC

class VideoCallViewController: UIViewController {

    // MARK: Property

    var hour = 0

    var minute = 0

    var second = 0

    let secondTimer = Timer()

    let minuteTimer = Timer()

    let hourTimer = Timer()

    var isCameraEnabled = true

    var isMicrophoneEnabled = true

    let rtcManager = QBRTCClient.instance()

    var videoCapture: QBRTCCameraCapture?

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var remoteVideoView: QBRTCRemoteVideoView!

    @IBOutlet weak var localVideoView: UIView!

    @IBOutlet weak var outletCamera: UIButton!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBOutlet weak var localvideoXConstraint: NSLayoutConstraint!

    @IBOutlet weak var localvideoYConstraint: NSLayoutConstraint!

    @IBAction func btnRotateCamera(_ sender: UIButton) {

        if let position = self.videoCapture?.position {

            switch position {

            case .back:

                self.videoCapture?.position = .front

            case .front:

                self.videoCapture?.position = .back

            default: break

            }

        }

    }

    @IBAction func btnCamera(_ sender: UIButton) {

        if isCameraEnabled {

            // MARK: User disabled the camera.

            isCameraEnabled = false

            outletCamera.setImage(
                UIImage(named: "icon-nocamera.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.videoTrack.isEnabled = false

            self.localVideoView.isHidden = true

        } else {

            // MARK: User enabled the camera.

            isCameraEnabled = true

            outletCamera.setImage(
                UIImage(named: "icon-camera.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.videoTrack.isEnabled = true

            self.localVideoView.isHidden = false

        }

    }

    @IBAction func btnMicrophone(_ sender: UIButton) {

        if isMicrophoneEnabled {

            // MARK: User muted the local microphone

            isMicrophoneEnabled = false

            outletMicrophone.setImage(
                UIImage(named: "icon-nomic.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.audioTrack.isEnabled = false

        } else {

            // MARK: User enabled the local microphone

            isMicrophoneEnabled = true

            outletMicrophone.setImage(
                UIImage(named: "icon-mic.png"),
                for: .normal
            )

            QBManager.shared.session?.localMediaStream.audioTrack.isEnabled = true

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        let duration = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        let roomId = UserManager.shared.chatRoomId

        let callinfo = [
            "callType": CallType.video.rawValue,
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
                    .video,
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

        rtcManager.add(self)

        if QBManager.shared.session == nil {

            guard
                let qbID = UserManager.shared.opponent?.quickbloxId,
                let qbIDInteger = Int(qbID),
                let opponentID = [qbIDInteger] as? [NSNumber]
                else {

                    return
            }

            QBManager.shared.session = QBRTCClient.instance().createNewSession(
                withOpponents: opponentID,
                with: .video
            )

            videoPreparation()

            UserManager.shared.startVideoCall()

        } else {

            videoPreparation()

            QBManager.shared.acceptCall()

        }

        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan)
        )

        localVideoView.addGestureRecognizer(pan)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.stopTimer()

    }

    // MARK: Selector Function

    func handlePan(_ recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: view.superview)

        localvideoXConstraint.constant += translation.x

        localvideoYConstraint.constant += translation.y

        recognizer.setTranslation(.zero, in: view.superview)

    }

    // MARK: Capture Video

    func videoPreparation() {

        let videoFormat = QBRTCVideoFormat.init()

        videoFormat.frameRate = 30

        videoFormat.pixelFormat = QBRTCPixelFormat.format420f

        videoFormat.width = 640

        videoFormat.height = 480

        videoCapture = QBRTCCameraCapture.init(
            videoFormat: videoFormat,
            position: AVCaptureDevicePosition.front
        )

        QBManager.shared.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture

        videoCapture!.previewLayer.frame = self.localVideoView.bounds

        videoCapture!.startSession()

        localVideoView.center = CGPoint(
            x: 0.0,
            y: 0.0
        )

        localVideoView.layer.insertSublayer(
            videoCapture!.previewLayer,
            at: 0
        )

        QBManager.shared.audioManager.currentAudioDevice = .speaker

    }

}

// MARK: Timer setting
extension VideoCallViewController {

    func configTimer() {

        let currentTime = DispatchTime.now()

        secondTimer.start(
            currentTime,
            interval: 1,
            repeats: true,
            handler: {

            if self.second == 59 {

                self.second = 0

            } else {

                self.second += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        })

        minuteTimer.start(
            currentTime + 60.0,
            interval: 60,
            repeats: true,
            handler: {

            if self.minute == 59 {

                self.minute = 0

            } else {

                self.minute += 1

            }

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        })

        hourTimer.start(
            currentTime + 3600.0,
            interval: 3600,
            repeats: true,
            handler: {

            self.hour += 1

            self.timeLabel.text = "\(self.hour.addLeadingZero()) : \(self.minute.addLeadingZero()) : \(self.second.addLeadingZero())"

        })
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

extension VideoCallViewController: QBRTCClientDelegate {

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        self.configTimer()

    }

    func session(_ session: QBRTCSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {

        // MARK: Received remote video track

        self.remoteVideoView.setVideoTrack(videoTrack)

        videoTrack.isEnabled = true

    }

}
