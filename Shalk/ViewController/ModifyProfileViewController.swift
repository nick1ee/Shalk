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
    
    var isChanged: Bool = false

    let imagePicker = UIImagePickerController()

    @IBOutlet weak var inputName: UITextField!

    @IBOutlet weak var inputIntro: UITextField!

    @IBOutlet weak var userImageView: UIImageView!

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnSave(_ sender: UIBarButtonItem) {

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

}

extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            userImageView.image = pickedImage

        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)

    }

}
