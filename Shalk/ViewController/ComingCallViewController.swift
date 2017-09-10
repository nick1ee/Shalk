//
//  ComingCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/7.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - ComingCallViewController

import UIKit
import Quickblox
import QuickbloxWebRTC

class ComingCallViewController: UIViewController {

    // MARK: Property

    var callType: CallType = .none

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentNameLabel: UILabel!

    @IBOutlet weak var callTypeLabel: UILabel!

    @IBOutlet weak var outletAcceptCall: UIButton!

    @IBOutlet weak var outletEndCall: UIButton!

    @IBAction func btnAcceptCall(_ sender: UIButton) {

        QBManager.shared.acceptCall()

        switch callType {

        case .audio:

            self.dismiss(
                animated: false,
                completion: {

                let audioCallViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioCallVC")

                AppDelegate.shared.window?.rootViewController?.present(
                    audioCallViewController,
                    animated: true,
                    completion: nil
                )
            })

        case .video:

            self.dismiss(
                animated: false,
                completion: {

                let videoCallViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoCallVC")

                AppDelegate.shared.window?.rootViewController?.present(
                    videoCallViewController,
                    animated: true,
                    completion: nil
                )
            })

        case .none: break

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        QBManager.shared.rejectCall(nil)

        self.dismiss(
            animated: true,
            completion: nil
        )
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonRadius()

        if let opponent = UserManager.shared.opponent {

            opponentNameLabel.text = opponent.name.addSpacingAndCapitalized()

            callTypeLabel.text = callType.rawValue

            if opponent.imageUrl != "null" {

                if let url = URL(string: opponent.imageUrl) {

                    opponentImageView.sd_setImage(with: url)

                }
            }
        }
    }

    // MARK: UI Customization

    func addButtonRadius() {

        let screen = UIScreen.main.bounds

        outletAcceptCall.layer.cornerRadius = screen.height / 16

        outletEndCall.layer.cornerRadius = screen.height / 16

    }

}
