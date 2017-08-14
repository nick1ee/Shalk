//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Firebase
import SVProgressHUD

class FirebaseManager {

    weak var friendDelegate: FirebaseManagerFriendDelegate?

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

                UserManager.shared.saveToken(email: email, pwd: pwd)

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

            SVProgressHUD.show(withStatus: "Registering on chat service.")

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

            withVC.pushLoginMessage(title: "Reset Password",

                                    message: "We have sent a link to your email, this is for you to reset your password.",

                                    handle: nil)
        }

    }

    func logOut() {

        do {

            try Auth.auth().signOut()

            // MARK: User log out Firebase successfully, start to log out with Quickblox.

            SVProgressHUD.show(withStatus: "Disconnected from chat service.")

            QBManager().logOut()

        } catch let error {

            // MARK: User failed to log out with Firebase.

            SVProgressHUD.dismiss()

            UIApplication.shared.endIgnoringInteractionEvents()

            UIAlertController(error: error).show()

        }

    }

}
