//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Firebase
import Crashlytics
import SVProgressHUD

class FirebaseManager {

    weak var chatRoomDelegate: FirebaseManagerChatRoomDelegate?

    var ref: DatabaseReference? = Database.database().reference()

    var handle: DatabaseHandle?

    let userManager = UserManager.shared

    let storage = Storage.storage()

    let storageRef = Storage.storage().reference()

    func logIn(withEmail email: String, withPassword pwd: String) {

        // MARK: Start to login Firebase

        Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in

            if error != nil {

                // MARK: User failed to sign in on Firebase.

                SVProgressHUD.dismiss()

                UIApplication.shared.endIgnoringInteractionEvents()

                UIAlertController(error: error!).show()

            }

            if let okUser = user {

                // MARK: User Signed in Firebase successfully, start sign in with Quickblox.

                QBManager().logIn(withEmail: email, withPassword: okUser.uid)

            }

        }

    }

    func signUp(name: String, withEmail email: String, withPassword pwd: String) {

        Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in

            if error != nil {

                // MARK: User failed to sign up on Firebase.

                SVProgressHUD.dismiss()

                UIApplication.shared.endIgnoringInteractionEvents()

                UIAlertController(error: error!).show()

            }

            guard let okUser = user else { return }

            // MARK: User sign up on Firebase successfully, start sign up on Quickblox.

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Register_ChatService", comment: ""))

            QBManager().signUp(name: name, uid: okUser.uid, withEmail: email, withPassword: okUser.uid)

            self.logIn(withEmail: email, withPassword: pwd)

        }

    }

    func resetPassword(_ withVC: UIViewController, withEmail email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            if error != nil {

                // MARK: Failed to reset password.
                UIAlertController(error: error!).show()

            }

            let alert = UIAlertController.init(title: NSLocalizedString("Reset_Password_Title", comment: ""), message: NSLocalizedString("Reset_Password_Message", comment: ""), preferredStyle: .alert)

            alert.addAction(title: "OK")

            withVC.present(alert, animated: true, completion: nil)

        }

    }

    func logOut() {

        do {

            try Auth.auth().signOut()

            // MARK: User log out Firebase successfully, start to log out with Quickblox.

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Logout_ChatService", comment: ""))

            QBManager().logOut()

        } catch let error {

            // MARK: User failed to log out with Firebase.

            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["info": "LogOut_Error"])

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            UIAlertController(error: error).show()

        }

    }

}
