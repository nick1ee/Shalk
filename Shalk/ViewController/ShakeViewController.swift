//
//  ShakeViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Magnetic
import SpriteKit
import Quickblox
import QuickbloxWebRTC
import NVActivityIndicatorView

class ShakeViewController: UIViewController {

    let rtcManager = QBRTCClient.instance()

    var session: QBRTCSession?

    var names = UIImage.names

    var selectedNode: Node?

    @IBOutlet weak var loadingView: NVActivityIndicatorView!

    @IBOutlet weak var labelSearching: UILabel!

    @IBOutlet weak var magneticView: MagneticView! {

        didSet {

            magnetic.magneticDelegate = self

        }

    }

    var magnetic: Magnetic {

        return magneticView.magnetic

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addLangBubbles(nil)

        labelSearching.isHidden = true

        rtcManager.add(self)

        QBRTCAudioSession.instance().initialize()

        QBRTCAudioSession.instance().currentAudioDevice = QBRTCAudioDevice.receiver

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        selectedNode = nil

        loadingView.stopAnimating()

        labelSearching.isHidden = true

    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if motion == .motionShake {

            guard let selectedLanguage = selectedNode?.text else {

                labelSearching.text = "Please select a preferred language."

                labelSearching.isHidden = false

                return

            }

            // MARK: Start pairing...

            loadingView.startAnimating()

            labelSearching.text = "Discovering, please wait."

            labelSearching.isHidden = false

            let currentTime = DispatchTime.now() + 3.0

            DispatchQueue.main.asyncAfter(deadline: currentTime, execute: {

                self.performSegue(withIdentifier: "audioCall", sender: nil)

            })

        }

    }

    @IBAction func addLangBubbles(_ sender: UIControl?) {

        for _ in 0...3 {

            let name = names.randomItem()

            names.removeAll(name)

            let color = UIColor.colors.randomItem()

            let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 40)

            magnetic.addChild(node)

        }

    }

}

extension ShakeViewController: QBRTCClientDelegate {

    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {

        if self.session != nil {

            let userInfo = ["key": "value"]

            session.rejectCall(userInfo)

        } else {

            self.session = session
            
            self.session?.acceptCall(nil)
            
            self.session?.localMediaStream.audioTrack.isEnabled = true

        }
    }

    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {

        audioTrack.isEnabled = true

    }

}

extension ShakeViewController: FirebaseManagerDelegate {

    func manager(_ manager: FirebaseManager, didGetOpponent: Opponent) {

        guard let opponent = [didGetOpponent.quickbloxID] as? [NSNumber] else { return }

        session = rtcManager.createNewSession(withOpponents: opponent, with: .audio)

        let userInfo = ["name": didGetOpponent.name, "image": didGetOpponent.imageURL]

        session?.startCall(userInfo)

    }

}

// MARK: - MagneticDelegate
extension ShakeViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {

        print("didSelect -> \(node)")

        selectedNode?.isSelected = false

        selectedNode = node

        selectedNode?.isSelected = true

    }

    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {

        print("didDeselect -> \(node)")

    }

}

// MARK: - ImageNode
class ImageNode: Node {

    override var image: UIImage? {

        didSet {

            sprite.texture = image.map { SKTexture(image: $0) }

        }
    }

    override func selectedAnimation() {}

    override func deselectedAnimation() {}

}
