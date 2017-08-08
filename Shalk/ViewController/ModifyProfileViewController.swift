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

    let imagePicker = UIImagePickerController()

    @IBOutlet weak var inputName: UITextField!

    @IBOutlet weak var inputIntro: UITextField!

    @IBOutlet weak var userImageView: UIImageView!

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnSave(_ sender: UIBarButtonItem) {

//        if isImageChanged == true {

            self.uploadUserImage()

//        }

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

        self.inputName.text = receivedUserName

        self.inputIntro.text = receivedUserIntro

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isImageChanged = false

    }

}

extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            userImageView.image = pickedImage

            isImageChanged = true

        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)

    }

}

extension ModifyProfileViewController {

    func uploadUserImage() {

        guard let data = UIImageJPEGRepresentation(userImageView.image!, 1) else { return }

        FirebaseManager().uploadImage(withData: data)

    }

}
