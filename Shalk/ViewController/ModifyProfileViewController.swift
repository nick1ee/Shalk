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

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnPickImage(_ sender: UIButton) {

        let alertController = UIAlertController.init(title: "Hint", message: "Send a image from..?", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction.init(title: "Camera", style: .default, handler: { (_) in

            self.imagePicker.sourceType = .camera

            self.present(self.imagePicker, animated: true, completion: nil)

        })

        let phoneLibraryAction = UIAlertAction.init(title: "Photo Library", style: .default, handler: {(_) in

            self.imagePicker.sourceType = .photoLibrary

            self.present(self.imagePicker, animated: true, completion: nil)

        })

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {(_) in

        })

        alertController.addAction(cameraAction)

        alertController.addAction(phoneLibraryAction)

        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        displayUserProfile()

    }

    func displayUserProfile() {

        guard let user = UserManager.shared.currentUser else { return }

        self.inputName.text = user.name

        self.inputIntro.text = user.intro

        DispatchQueue.global().async {

            self.userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(named: "icon-user"))

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
