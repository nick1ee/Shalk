//
//  LoginViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import SwifterSwift
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var iconEmail: UIImageView!
    @IBOutlet weak var iconKey: UIImageView!

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!

    @IBAction func btnLogin(_ sender: UIButton) {

        if !inputEmail.isEmpty && !inputPassword.isEmpty {

            guard let email = inputEmail.text, let pwd = inputPassword.text else { return }

            SVProgressHUD.show(withStatus: "Start to log in")

            // MARK: User start to log in.

            UserManager.shared.logIn(withEmail: email, withPassword: pwd)

        } else {

            if inputEmail.isEmpty {

                iconEmail.tintColor = UIColor.red

            } else {

                iconEmail.tintColor = UIColor.init(red: 255/255, green: 189/255, blue: 0/255, alpha: 1)
            }

            if inputPassword.isEmpty {

                iconKey.tintColor = UIColor.red

            } else {

                iconKey.tintColor = UIColor.init(red: 255/255, green: 189/255, blue: 0/255, alpha: 1)

            }

            let alert = UIAlertController(title: "Error!", message: "Please fullfill all required fileds", preferredStyle: .alert)
            alert.addAction(title: "OK")
            alert.show()

        }

    }

    @IBAction func btnCreateNewAccount(_ sender: UIButton) {

        let registerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "registerVC")

        self.present(registerVC, animated: true, completion: nil)

    }

    @IBAction func btnResetPassword(_ sender: UIButton) {

        if !inputEmail.isEmpty {

            guard let email = inputEmail.text else { return }

            FirebaseManager().resetPassword(self, withEmail: email)

        } else {

            if inputEmail.isEmpty {

                iconEmail.tintColor = UIColor.red
            }

            let alert = UIAlertController(title: "Error!", message: "Enter your email, we will send you a link to reset password1", preferredStyle: .alert)
            alert.addAction(title: "OK")
            alert.show()

        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        iconEmail.tintColor = UIColor.lightGray

        iconKey.tintColor = UIColor.lightGray

    }

}
