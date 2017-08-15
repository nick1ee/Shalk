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

    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!

    @IBAction func btnLogin(_ sender: UIButton) {

        if !inputEmail.isEmpty && !inputPassword.isEmpty {

            guard let email = inputEmail.text, let pwd = inputPassword.text else { return }

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Login", comment: ""))

            // MARK: User start to log in.

            UserManager.shared.logIn(withEmail: email, withPassword: pwd)

        } else {

            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Empty_Field", comment: ""), preferredStyle: .alert)

            alert.addAction(title: NSLocalizedString("OK", comment: ""))

            self.present(alert, animated: true, completion: nil)

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

            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Reset_Password", comment: ""), preferredStyle: .alert)

            alert.addAction(title: NSLocalizedString("OK", comment: ""))

            self.present(alert, animated: true, completion: nil)

        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Add padding for textfields.

        inputEmail.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 30)

        inputPassword.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 30)

    }

}
