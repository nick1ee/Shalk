//
//  VideoCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class VideoCallViewController: UIViewController {

    var hour = 0

    var minute = 0

    var second = 0

    var secondTimer = Timer()

    var minuteTimer = Timer()

    var hourTimer = Timer()

    var location = CGPoint(x: 0, y: 0)

    var isCameraEnabled = true

    var isMicrophoneEnabled = true

    let rtcManager = QBRTCClient.instance()

    var videoCapture: QBRTCCameraCapture?

    let qbManager = QBManager.shared

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var remoteVideoView: QBRTCRemoteVideoView!

    @IBOutlet weak var localVideoView: UIView!

    @IBOutlet weak var connectionStatus: UILabel!

    @IBOutlet weak var outletCamera: UIButton!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBAction func btnRotateCamera(_ sender: UIButton) {

        let position = self.videoCapture?.position

        switch position! {

        case .back:

            self.videoCapture?.position = .front

            break

        case .front:

            self.videoCapture?.position = .back

            break

        default: break

        }

    }

    @IBAction func btnCamera(_ sender: UIButton) {

        if isCameraEnabled {

            // MARK: User disabled the camera.

            isCameraEnabled = false

            outletCamera.setImage(UIImage(named: "icon-nocamera.png"), for: .normal)

            QBManager.shared.session?.localMediaStream.videoTrack.isEnabled = false

        } else {

            // MARK: User enabled the camera.

            isCameraEnabled = true

            outletCamera.setImage(UIImage(named: "icon-camera.png"), for: .normal)

            QBManager.shared.session?.localMediaStream.videoTrack.isEnabled = true

        }

    }

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

    @IBAction func btnEndCall(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

        QBManager.shared.handUpCall()

        UserManager.shared.isConnected = false

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        localVideoView.center = CGPoint(x: 0, y: 0)

        rtcManager.add(self)

        if UserManager.shared.callType == .video {

            videoPreparation()

            QBManager.shared.acceptCall()

        } else {

            guard
                let qbID = UserManager.shared.opponent?.quickbloxId,
                let qbIDInteger = Int(qbID),
                let opponentID = [qbIDInteger] as? [NSNumber] else { return }

            QBManager.shared.session = QBRTCClient.instance().createNewSession(withOpponents: opponentID, with: .video)

            videoPreparation()

            UserManager.shared.startVideoCall()

        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))

        localVideoView.addGestureRecognizer(panGesture)

    }

    func videoPreparation() {

        let videoFormat = QBRTCVideoFormat.init()

        videoFormat.frameRate = 30

        videoFormat.pixelFormat = QBRTCPixelFormat.format420f

        videoFormat.width = 640

        videoFormat.height = 480

        self.videoCapture = QBRTCCameraCapture.init(videoFormat: videoFormat, position: AVCaptureDevicePosition.front)

        QBManager.shared.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture

        self.videoCapture!.previewLayer.frame = self.localVideoView.bounds

        self.videoCapture!.startSession()

        self.localVideoView.layer.insertSublayer(videoCapture!.previewLayer, at: 0)

    }

    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {

            let translation = gestureRecognizer.translation(in: self.view)

            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }

    }

}

// MARK: Timer setting
extension VideoCallViewController {

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

extension VideoCallViewController: QBRTCClientDelegate {

    // MARK: 連線確定與該使用者進行連接
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {

        connectionStatus.text = "Video Connected"

        self.enableTimer()

    }

    func session(_ session: QBRTCSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {

        // MARK: Received remote video track

        self.remoteVideoView.setVideoTrack(videoTrack)

        videoTrack.isEnabled = true

    }

}
