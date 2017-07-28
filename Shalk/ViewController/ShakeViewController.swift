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

class ShakeViewController: UIViewController {

    var names = UIImage.names
    
    var selectedNode: Node?

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

        for _ in 0...3 {

            self.add(nil)

        }

    }

    @IBAction func add(_ sender: UIControl?) {

        let name = names.randomItem()

        names.removeAll(name)

        let color = UIColor.colors.randomItem()

        let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 40)

        magnetic.addChild(node)

    }

}

// MARK: - MagneticDelegate
extension ShakeViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {

        print("didSelect -> \(node)")

        selectedNode?.isSelected = false

        selectedNode = node

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
