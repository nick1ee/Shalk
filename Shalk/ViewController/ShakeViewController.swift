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

        selectedNode?.isSelected = false

        selectedNode = nil

        loadingView.stopAnimating()

        labelSearching.isHidden = true

        UserManager.shared.isDiscovering = false

    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if UserManager.shared.isDiscovering == false {

            UserManager.shared.isDiscovering = true

            if motion == .motionShake {

                guard let selectedLanguage = selectedNode?.text else {

                    labelSearching.text = "Please select a preferred language."

                    labelSearching.isHidden = false

                    UserManager.shared.isDiscovering = false

                    return

                }

                UserManager.shared.discoveredLanguage = selectedLanguage

                // MARK: Start pairing...

                loadingView.startAnimating()

                labelSearching.text = "Discovering, please wait!"

                labelSearching.isHidden = false

                FirebaseManager().fetchChannel(withLang: selectedLanguage)

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

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "audioCall" {
//
//            let destinationNavi = segue.destination as? UINavigationController
//
//            let audioVC = destinationNavi?.viewControllers.first as? RandomCallViewController
//
//            guard let opponentName = userManager.opponent?.name else { return }
//
//            audioVC?.receivedUserName = opponentName
//
//        }
//
//    }

}

// MARK: - MagneticDelegate
extension ShakeViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {

        // MAKR: Bubble selected
        userManager.closeChannel()

        UserManager.shared.isDiscovering = false

        labelSearching.isHidden = true

        loadingView.stopAnimating()

        selectedNode?.isSelected = false

        selectedNode = node

        selectedNode?.isSelected = true

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
