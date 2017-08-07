//
//  ComingCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/7.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ComingCallViewController: UIViewController {

    let opponent = UserManager.shared.opponent

    var callTypeString = ""

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentNameLabel: UILabel!

    @IBOutlet weak var callType: UILabel!

    @IBAction func btnAcceptCall(_ sender: UIButton) {

        QBManager.shared.acceptCall()

        switch callTypeString {

        case "Audio Call":

            self.performSegue(withIdentifier: "acceptAudioCall", sender: nil)

            self.dismiss(animated: false, completion: nil)

        default:

            self.performSegue(withIdentifier: "acceptVideoCall", sender: nil)

            self.dismiss(animated: false, completion: nil)

        }

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

        QBManager.shared.handUpCall()

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        opponentNameLabel.text = opponent?.name

        callType.text = callTypeString

    }

}
