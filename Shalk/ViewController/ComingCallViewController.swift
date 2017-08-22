//
//  ComingCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/7.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class ComingCallViewController: UIViewController {

    var isCallAccepted: Bool = false

    let opponent = UserManager.shared.opponent

    var callType: CallType = .none

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentNameLabel: UILabel!

    @IBOutlet weak var callTypeLabel: UILabel!

    @IBOutlet weak var outletAcceptCall: UIButton!

    @IBOutlet weak var outletEndCall: UIButton!

    @IBAction func btnAcceptCall(_ sender: UIButton) {

        QBManager.shared.acceptCall()

        self.isCallAccepted = true

        switch callType {

        case .audio:

            self.dismiss(animated: false, completion: {

                let audioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioCallVC")

                AppDelegate.shared.window?.rootViewController?.present(audioVC, animated: true, completion: nil)

            })

            break

        case .video:

            self.dismiss(animated: false, completion: {

                let videoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoCallVC")

                AppDelegate.shared.window?.rootViewController?.present(videoVC, animated: true, completion: nil)

            })

            break

        case .none: break

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        QBManager.shared.rejectCall(nil)

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonRadius()

        opponentNameLabel.text = opponent?.name.addSpacingAndCapitalized()

        callTypeLabel.text = callType.rawValue

        if opponent?.imageUrl != "null" {

            opponentImageView.sd_setImage(with: URL(string: (opponent?.imageUrl)!))

        }

    }

    func addButtonRadius() {

        let screen = UIScreen.main.bounds

        outletAcceptCall.layer.cornerRadius = screen.height / 14

        outletEndCall.layer.cornerRadius = screen.height / 14

    }

}
