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

    var isCameraEnabled = true

    var isMicrophoneEnabled = true

    let rtcManager = QBRTCClient.instance()

    var videoCapture: QBRTCCameraCapture?

    let qbManager = QBManager.shared

    @IBOutlet weak var remoteVideoView: QBRTCRemoteVideoView!

    @IBOutlet weak var localVideoView: UIView!

    @IBOutlet weak var outletCamera: UIButton!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBAction func btnCamera(_ sender: UIButton) {

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

        captureVideoAndAudio()

        rtcManager.add(self)

    }

    func captureVideoAndAudio() {

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

}

extension VideoCallViewController: QBRTCClientDelegate {

    func session(_ session: QBRTCSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {

        print("Gotcha Video")

        // MARK: Received remote video track

        self.remoteVideoView.setVideoTrack(videoTrack)

        videoTrack.isEnabled = true

    }

}
