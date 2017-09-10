//
//  EULAViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/21.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: EULAViewController

import UIKit

class EULAViewController: UIViewController {

    // MARK: Property

    @IBOutlet weak var eulaTextView: UITextView!

    @IBAction func btnBack(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        eulaTextView.isEditable = false

        UIApplication.shared.statusBarStyle = .default

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.statusBarStyle = .lightContent

    }

}
