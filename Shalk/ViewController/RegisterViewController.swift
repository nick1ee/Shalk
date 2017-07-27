//
//  RegisterViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var iconUser: UIImageView!

    @IBOutlet weak var iconEmail: UIImageView!

    @IBOutlet weak var iconKey: UIImageView!

    @IBOutlet weak var inputUserName: UITextField!

    @IBOutlet weak var inputEmail: UITextField!

    @IBOutlet weak var inputPassword: UITextField!

    @IBAction func btnSignUp(_ sender: UIButton) {

    }

    @IBAction func btnBackToLogin(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        iconUser.tintColor = UIColor.lightGray

        iconEmail.tintColor = UIColor.lightGray

        iconKey.tintColor = UIColor.lightGray

    }

}
