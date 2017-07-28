//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {

    var ref = Database.database().reference()

    let profile = ProfileManager.shared

    var tempUser: User?

    func logIn(_ withVC: UIViewController, withEmail email: String, withPassword pwd: String) {

        // MARK: Start to login Firebase

        Auth.auth().signIn(withEmail: email, password: pwd) { (_, error) in

            if error != nil {

                // TODO: Error handling
                print(error?.localizedDescription ?? "No error data")

            }

            // MARK: User Signed in successfully.

            withVC.pushLoginMessage(title: "Successfully",

                                           message: "You have signed in successfully! Click OK to main page. ",

                                           handle: { _ in

                                            let mainTabVC = UIStoryboard(name: "Main",

                                                                       bundle: nil).instantiateViewController(withIdentifier: "mainTabVC")

                                            AppDelegate.shared.window?.rootViewController = mainTabVC

            })

        }

    }

    func signUp(_ withVC: UIViewController, withUser name: String, withEmail email: String, withPassword pwd: String) {

        Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in

            if error != nil {

                // TODO: Error handling
                print(error?.localizedDescription ?? "No error data")

            }

            guard let okUser = user else { return }

            QBManager().signUp(withEmail: email, withPassword: pwd)

            self.profile.currentUser = User(name: name,

                                            uid: okUser.uid,

                                            email: email,

                                            quickbloxID: 0,

                                            preferredLanguages: [PreferredLangauge.notSelected.rawValue])

            let request = okUser.createProfileChangeRequest()

            request.displayName = name

            request.commitChanges(completion: { (error) in

                if error != nil {

                    // TODO: Error handling
                    print(error?.localizedDescription ?? "No error data")

                }

                self.logIn(withVC, withEmail: email, withPassword: pwd)

            })

        }

    }

    func resetPassword(_ withVC: UIViewController, withEmail email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in

            if error != nil {

                // TODO: Error handling
                print(error?.localizedDescription ?? "No error data")

            }

            withVC.pushLoginMessage(title: "Reset Password",

                                           message: "We have sent a link to your email, this is for you to reset your password.",

                                           handle: nil)
        }

    }

}
