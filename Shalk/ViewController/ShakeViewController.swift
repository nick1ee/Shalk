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
import AudioToolbox
import QuickbloxWebRTC
import NVActivityIndicatorView

class ShakeViewController: UIViewController {

    let rtcManager = QBRTCClient.instance()

    let qbManager = QBManager.shared

    let userManager = UserManager.shared

    var names = UIImage.names

    var selectedNode: Node?

    @IBOutlet weak var iconShake: UIImageView!

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

        magnetic.allowsMultipleSelection = false

        magnetic.backgroundColor = UIColor.clear

        iconShake.tintColor = UIColor.white

        addLangBubbles(nil)

        QBManager.shared.audioManager.initialize()

        QBManager.shared.audioManager.currentAudioDevice = QBRTCAudioDevice.receiver

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        userManager.opponent = nil

        UserManager.shared.isDiscovering = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        selectedNode = nil

        loadingView.stopAnimating()

        labelSearching.text = "Shake your mobile to find the partner!"

        iconShake.isHidden = false

        UserManager.shared.isDiscovering = false

        FirebaseManager().leaveChannel()

    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if UserManager.shared.isDiscovering == false {

            UserManager.shared.isDiscovering = true

            if motion == .motionShake {

                guard let selectedLanguage = selectedNode?.text else {

                    labelSearching.text = "Please select a preferred language."

                    UserManager.shared.isDiscovering = false

                    return

                }

                UserManager.shared.discoveredLanguage = selectedLanguage

                // MARK: Start pairing...

                iconShake.isHidden = true

                loadingView.startAnimating()

                labelSearching.text = "Discovering, please wait!"

                FirebaseManager().fetchChannel(withLanguage: selectedLanguage)

            }

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

// MARK: - MagneticDelegate
extension ShakeViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {

        // MAKR: Bubble selected
        userManager.closeChannel()

        labelSearching.text = "Shake your mobile to find the partner!"

        UserManager.shared.isDiscovering = false

        loadingView.stopAnimating()

        selectedNode = node

    }

    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {

        // MARK: Bubble deselected.

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
