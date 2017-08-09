//
//  ModifyProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/8.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ModifyProfileViewController: UIViewController {

    var receivedUserName = ""

    var receivedUserIntro = ""

    var isImageChanged: Bool = false

    var isProfileChanged: Bool = false

    let imagePicker = UIImagePickerController()

    @IBOutlet weak var iconUser: UIImageView!

    @IBOutlet weak var iconIntro: UIImageView!

    @IBOutlet weak var inputName: UITextField!

    @IBOutlet weak var inputIntro: UITextField!

    @IBOutlet weak var userImageView: UIImageView!

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnSave(_ sender: UIBarButtonItem) {

        if isImageChanged == true {

            self.uploadUserImage()

        }

        guard let user = UserManager.shared.currentUser else { return }

        if inputName.text != user.name || inputIntro.text != user.intro {

            isProfileChanged = true

            self.updateUserProfile()

        }

        guard let myUid = UserManager.shared.currentUser?.uid else { return }

        FirebaseManager().fetchUserProfile(withUid: myUid, type: .myself, call: .none)

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnPickImage(_ sender: UIButton) {

        let alertController = UIAlertController.init(title: "Hint", message: "Choose a photo from .. ?", preferredStyle: .actionSheet)

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
        
        guard let user = UserManager.shared.currentUser else { return }

        self.inputName.text = user.name

        self.inputIntro.text = user.intro
        
        self.userImageView.sd_setImage(with: URL(string: user.imageUrl))

    }

}

extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            self.isImageChanged = true

            userImageView.image = pickedImage

        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)

    }

}

extension ModifyProfileViewController {

    func uploadUserImage() {

        guard let data = UIImageJPEGRepresentation(userImageView.image!, 0.7) else { return }

        FirebaseManager().uploadImage(withData: data)

        self.isImageChanged = false

    }

    func updateUserProfile() {

        guard let name = inputName.text, let intro = inputIntro.text else { return }

        FirebaseManager().updateUserProfile(withName: name, withIntro: intro)

        self.isProfileChanged = false

    }

}
