//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let userManager = UserManager.shared

    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var labelUserName: UILabel!

    @IBOutlet weak var labelUserIntro: UILabel!

    @IBOutlet weak var labelUserEmail: UILabel!

    @IBOutlet weak var labelPreferLang1: UILabel!

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayUserInfo()

    }

    func displayUserInfo() {

        guard let currentUser = userManager.currentUser else { return }

        labelUserName.text = currentUser.name

        labelUserEmail.text = currentUser.email

    }

}
