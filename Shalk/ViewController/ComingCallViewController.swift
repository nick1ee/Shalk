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

    var callTypeString = ""

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentNameLabel: UILabel!

    @IBOutlet weak var callType: UILabel!

    @IBOutlet weak var outletAcceptCall: UIButton!

    @IBOutlet weak var outletEndCall: UIButton!

    @IBAction func btnAcceptCall(_ sender: UIButton) {

        QBManager.shared.acceptCall()

        self.isCallAccepted = true

        switch callTypeString {

        case "Audio Call":

            UserManager.shared.callType = .audio

            self.performSegue(withIdentifier: "acceptAudioCall", sender: nil)

        default:

            UserManager.shared.callType = .video

            self.performSegue(withIdentifier: "acceptVideoCall", sender: nil)

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        QBManager.shared.rejectCall(nil)

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonRadius()

        opponentNameLabel.text = opponent?.name

        callType.text = callTypeString

        if opponent?.imageUrl != "null" {

            opponentImageView.sd_setImage(with: URL(string: (opponent?.imageUrl)!))

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isCallAccepted == true {

            self.dismiss(animated: true, completion: nil)

            isCallAccepted = false

        }

    }

    func addButtonRadius() {

        let screen = UIScreen.main.bounds

        outletAcceptCall.layer.cornerRadius = screen.height / 14

        outletEndCall.layer.cornerRadius = screen.height / 14

    }

}
