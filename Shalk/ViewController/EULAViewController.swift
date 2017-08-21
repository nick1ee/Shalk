//
//  EULAViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/21.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    @IBOutlet weak var eulaTextView: UITextView!

    @IBAction func btnBack(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

}
