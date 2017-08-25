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

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var inputUserName: UITextField!

    @IBOutlet weak var inputEmail: UITextField!

    @IBOutlet weak var inputPassword: UITextField!

    @IBAction func btnSignUp(_ sender: UIButton) {

        if !inputUserName.isEmpty && !inputEmail.isEmpty && !inputPassword.isEmpty {

            // MARK: 1. Check email format and password should have 6 character at least.

            guard let name = inputUserName.text, let email = inputEmail.text, let pwd = inputPassword.text else { return }

            if email.isValidEmail() == true {

                if  pwd.characters.count >= 6 {

                    SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Register", comment: ""))

                    UserManager.shared.signUp(name: name, withEmail: email, withPassword: pwd)

                } else {

                    // MARK: Invalid password.

                    let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Invalid_Password", comment: ""), preferredStyle: .alert)

                    alert.addAction(title: NSLocalizedString("OK", comment: ""))

                    self.present(alert, animated: true, completion: nil)

                }

            } else {

                // MARK: Invalid email format.

                let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Invalid_Email", comment: ""), preferredStyle: .alert)

                alert.addAction(title: NSLocalizedString("OK", comment: ""))

                self.present(alert, animated: true, completion: nil)

            }

        } else {

            let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Empty_Field", comment: ""), preferredStyle: .alert)

            alert.addAction(title: NSLocalizedString("OK", comment: ""))

            self.present(alert, animated: true, completion: nil)

        }

    }

    @IBAction func btnBackToLogin(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }

    @IBAction func checkEULA(_ sender: UIButton) {

        let eulaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EULAVC")

        self.present(eulaVC, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputUserName.delegate = self

        inputEmail.delegate = self

        inputPassword.delegate = self

        adjustTextfield()

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        self.view.addGestureRecognizer(tap)

    }

    func adjustTextfield() {

        inputUserName.maxLength = 20

        inputEmail.maxLength = 30

        inputPassword.maxLength = 12

    }

    func hideKeyboard() {

        self.view.endEditing(true)

    }

    deinit {

        NotificationCenter.default.removeObserver(self)

    }

}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true

    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)

        return true

    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        scrollView.contentInset = UIEdgeInsets.zero

    }

    func keyboardWillShow(notification: Notification) {

        let userInfo: NSDictionary = notification.userInfo! as NSDictionary

        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)

        scrollView.contentInset = contentInsets

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
