//
//  ModifyProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/8.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ModifyProfileViewController: UIViewController {

    let imagePicker = UIImagePickerController()

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var iconUser: UIImageView!

    @IBOutlet weak var iconIntro: UIImageView!

    @IBOutlet weak var inputName: UITextField!

    @IBOutlet weak var inputIntro: UITextField!

    @IBOutlet weak var userImageView: UIImageView!

    @IBAction func nameTextfield(_ sender: UITextField) {

        guard let user = UserManager.shared.currentUser else { return }

        if !inputName.isEmpty && inputName.text != user.name {

            let updatedName = inputName.text!

            FirebaseManager().updateUserName(name: updatedName)

        }

    }

    @IBAction func introTextfield(_ sender: UITextField) {

        guard let user = UserManager.shared.currentUser else { return }

        if !inputIntro.isEmpty && inputIntro.text != user.intro {

            let updatedIntro = inputIntro.text!

            FirebaseManager().updateUserIntro(intro: updatedIntro)

        }

    }

    @IBAction func btnBack(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnPickImage(_ sender: UIButton) {

        let alertController = UIAlertController.init(title: "", message: NSLocalizedString("ImagePicker_Title", comment: ""), preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction.init(title: NSLocalizedString("Camera", comment: ""), style: .default, handler: { (_) in

            self.imagePicker.sourceType = .camera

            self.present(self.imagePicker, animated: true, completion: nil)

        })

        let phoneLibraryAction = UIAlertAction.init(title: NSLocalizedString("PhotoLibrary", comment: ""), style: .default, handler: {(_) in

            self.imagePicker.sourceType = .photoLibrary

            self.present(self.imagePicker, animated: true, completion: nil)

        })

        let cancelAction = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(_) in

        })

        alertController.addAction(cameraAction)

        alertController.addAction(phoneLibraryAction)

        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        inputName.delegate = self

        inputIntro.delegate = self

        adjustTextfield()

        displayUserProfile()

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        self.view.addGestureRecognizer(tap)

    }

    func adjustTextfield() {

        // MARK: Add padding for textfields.

        inputName.maxLength = 20

        inputIntro.maxLength = 40

        inputName.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("InputName", comment: ""),
                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])

        inputIntro.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("InputIntro", comment: ""),
                                                             attributes: [NSForegroundColorAttributeName: UIColor.white])

    }

    func hideKeyboard() {

        self.view.endEditing(true)

    }

    deinit {

        NotificationCenter.default.removeObserver(self)

    }

    func displayUserProfile() {

        iconIntro.tintColor = UIColor.white

        iconUser.tintColor = UIColor.white

        userImageView.tintColor = UIColor.white

        guard let user = UserManager.shared.currentUser else { return }

        inputName.text = user.name

        if user.intro != "null" {

            inputIntro.text = user.intro

        }

        if user.imageUrl != "null" {

            userImageView.sd_setImage(with: URL(string: user.imageUrl))

        }

    }

}

extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            userImageView.image = pickedImage

            let imageData = UIImageJPEGRepresentation(userImageView.image!, 0.7)

            FirebaseManager().uploadImage(withData: imageData!)

        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)

    }

}

extension ModifyProfileViewController: UITextFieldDelegate {

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
