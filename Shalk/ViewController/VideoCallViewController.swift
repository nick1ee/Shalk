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

    var videoCapture: QBRTCCameraCapture?

    @IBOutlet weak var remoteVideoView: QBRTCRemoteVideoView!

    @IBOutlet weak var localVideoView: UIView!

    @IBOutlet weak var outletCamera: UIButton!

    @IBOutlet weak var outletMicrophone: UIButton!

    @IBAction func btnCamera(_ sender: UIButton) {

    }

    @IBAction func btnSpeaker(_ sender: UIButton) {

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureVideoAndAudio()

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

    func session(_ session: QBRTCSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {

        print("Gotcha Audio")

        // MARK: Received remote audio track

        audioTrack.isEnabled = true

    }

}
