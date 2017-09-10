//
//  ShakeViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - ShakeViewController

import UIKit
import Magnetic
import SpriteKit
import Quickblox
import QuickbloxWebRTC
import NVActivityIndicatorView

class ShakeViewController: UIViewController {

    // MARK: Property

    let rtcManager = QBRTCClient.instance()

    var selectedNode: Node?

    var nodes: [Node] = []

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

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpBackgroundView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        iconShake.isHidden = true

        labelSearching.text = NSLocalizedString("No_Language", comment: "")

        addLangBubbles()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        QBManager.shared.session = nil

        UserManager.shared.isDiscovering = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        selectedNode?.isSelected = false

        selectedNode = nil

        loadingView.stopAnimating()

        labelSearching.text = NSLocalizedString("Shake_Hint", comment: "")

        iconShake.isHidden = false

        UserManager.shared.isDiscovering = false

        DispatchQueue.global().async {

            FirebaseManager().leaveChannel()

        }

    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if selectedNode == nil {

            labelSearching.text = NSLocalizedString("No_Language", comment: "")

        } else {

            UserManager.shared.opponent = nil

            if UserManager.shared.isDiscovering == false {

                // MARK: Start Pairing

                UserManager.shared.isDiscovering = true

                if motion == .motionShake {

                    FirebaseManager().logEvent("shake_mobile")

                    UserManager.shared.language = (selectedNode?.text)!

                    iconShake.isHidden = true

                    loadingView.startAnimating()

                    labelSearching.text = NSLocalizedString("Discovering", comment: "")

                    FirebaseManager().fetchChannel()

                }

            } else {

                labelSearching.text = NSLocalizedString("Double_Shake", comment: "")

            }

        }

    }

    // MARK: UI Customization

    func setUpBackgroundView() {

        magneticView.allowsTransparency = true

        magnetic.allowsMultipleSelection = false

        magneticView.backgroundColor = UIColor.clear

        magnetic.backgroundColor = UIColor.clear

        let shakeImage = UIImage(named: "icon-shake")

        iconShake.image = shakeImage

        iconShake.image = iconShake.image?.withRenderingMode(.alwaysTemplate)

        iconShake.tintColor = UIColor.white

    }

    // MARK: Add Bubbles

    func addLangBubbles() {

        for node in nodes {

            node.removeFromParent()

        }

        nodes = []

        var colorArray = UIColor.colors

        for item in 0...3 {

            let language = UIImage.languages[item]

            let color = colorArray.randomItem

            colorArray.removeAll(color)

            let node = Node(text: language.capitalized, image: UIImage(named: language), color: color, radius: UIScreen.main.bounds.width / 9)

            magnetic.addChild(node)

            nodes.append(node)

        }

    }

}

// MARK: MagneticDelegate

extension ShakeViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {

        // MARK: Bubble selected

        labelSearching.text = NSLocalizedString("Shake_Hint", comment: "")

        selectedNode = node

        iconShake.isHidden = false

    }

    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {

        selectedNode = nil

        DispatchQueue.global().async {

            FirebaseManager().closeChannel()

        }

        UserManager.shared.isDiscovering = false

        loadingView.stopAnimating()

        iconShake.isHidden = true

        labelSearching.text = NSLocalizedString("No_Language", comment: "")

    }

}

// MARK: ImageNode

class ImageNode: Node {

    override var image: UIImage? {

        didSet {

            sprite.texture = image.map { SKTexture(image: $0) }

        }
    }

    override func selectedAnimation() {}

    override func deselectedAnimation() {}

}
