//
//  RegisterViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var inputUserName: UITextField!

    @IBOutlet weak var inputEmail: UITextField!

    @IBOutlet weak var inputPassword: UITextField!

    @IBAction func btnSignUp(_ sender: UIButton) {

        if !inputUserName.isEmpty && !inputEmail.isEmpty && !inputPassword.isEmpty {

            // MARK: 1. Check email format and password should have 8 character at least.

            guard let name = inputUserName.text, let email = inputEmail.text, let pwd = inputPassword.text else { return }

            if email.isValidEmail() == true {

                if  pwd.characters.count >= 8 {

                    SVProgressHUD.show(withStatus: "Registering a new account")

                    UserManager.shared.signUp(name: name, withEmail: email, withPassword: pwd)

                } else {

                    // MARK: Invalid password.

                    let alert = UIAlertController(title: "Error!", message: "Password should have 8 characters at least.", preferredStyle: .alert)

                    alert.addAction(title: "OK")

                    self.present(alert, animated: true, completion: nil)

                }

            } else {

                // MARK: Invalid email format.

                let alert = UIAlertController(title: "Error!", message: "Please enter a valid email account", preferredStyle: .alert)

                alert.addAction(title: "OK")

                self.present(alert, animated: true, completion: nil)

            }

        } else {

            let alert = UIAlertController(title: "Error!", message: "Please fullfill all required fileds to apply a new account", preferredStyle: .alert)

            alert.addAction(title: "OK")

            self.present(alert, animated: true, completion: nil)

        }

    }

    @IBAction func btnBackToLogin(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputUserName.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 30)

        inputEmail.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 30)

        inputPassword.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 30)

    }

}

extension String {

    func isValidEmail() -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        let result = emailTest.evaluate(with: self)

        return result

    }

}
