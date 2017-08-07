//
//  ComingCallViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/7.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ComingCallViewController: UIViewController {

    var opponentName = ""

    var callTypeString = ""

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentNameLabel: UILabel!

    @IBOutlet weak var callType: UILabel!

    @IBAction func btnAcceptCall(_ sender: UIButton) {

    }

    @IBAction func btnEndCall(_ sender: UIButton) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        opponentNameLabel.text = opponentName

        callType.text = callTypeString

    }

}
