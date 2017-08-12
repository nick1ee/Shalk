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

    @IBOutlet weak var iconUser: UIImageView!

    @IBOutlet weak var iconEmail: UIImageView!

    @IBOutlet weak var iconKey: UIImageView!

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

                    iconKey.tintColor = UIColor.red

                    let alert = UIAlertController(title: "Error!", message: "Password should have 8 characters at least.", preferredStyle: .alert)

                    alert.addAction(title: "OK")

                    self.present(alert, animated: true, completion: nil)

                }

            } else {

                // MARK: Invalid email format.

                iconEmail.tintColor = UIColor.red

                let alert = UIAlertController(title: "Error!", message: "Please enter a valid email account", preferredStyle: .alert)

                alert.addAction(title: "OK")

                self.present(alert, animated: true, completion: nil)

            }

        } else {

            if inputUserName.isEmpty {

                iconUser.tintColor = UIColor.red

            } else {

                iconUser.tintColor = UIColor.init(red: 255/255, green: 189/255, blue: 0/255, alpha: 1)

            }

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

        iconUser.tintColor = UIColor.lightGray

        iconEmail.tintColor = UIColor.lightGray

        iconKey.tintColor = UIColor.lightGray

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
