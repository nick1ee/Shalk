//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseManagerDelegate {

    func manager (_ manager: FirebaseManager, didGetOpponent: Opponent)

}

class FirebaseManager {

    var ref: DatabaseReference? = Database.database().reference()

//    var handle: DatabaseHandle?

    let profile = ProfileManager.shared

    var tempUser: User?

    var delegate: FirebaseManagerDelegate?

    func logIn(_ withVC: UIViewController, withEmail email: String, withPassword pwd: String) {

        // MARK: Start to login Firebase

        Auth.auth().signIn(withEmail: email, password: pwd) { (user, error) in

            if error != nil {

                // TODO: Error handling
                print(error?.localizedDescription ?? "No error data")

            }

            if user != nil {

                QBManager().logIn(withEmail: email, withPassword: pwd)

                // MARK: User Signed in successfully.

                withVC.pushLoginMessage(title: "Successfully",

                                        message: "You have signed in successfully! Click OK to main page. ",

                                        handle: { _ in

                                            self.profile.fetchUserData()

                                            let mainTabVC = UIStoryboard(name: "Main",

                                                                         bundle: nil).instantiateViewController(withIdentifier: "mainTabVC")

                                            AppDelegate.shared.window?.rootViewController = mainTabVC

                })

            }

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

    func logOut() {

    }

    func fetchUserProfile() {

        guard let userID = Auth.auth().currentUser?.uid else { return }

        ref?.child("users").child(userID).observeSingleEvent(of: .value, with: {(snapshot) in

            guard let object = snapshot.value as? [String: Any] else { return }

            do {

                let user = try User.init(json: object)

                self.profile.currentUser = user

                print("user:", user)

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)
            }

        })

    }

    func checkChatPool(selected language: String) {

        ref?.child("chatPool").child(language).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let onlineUsers = snapshot.value as? [String] else { return }

            self.ref?.child("users").child(onlineUsers.randomItem).observeSingleEvent(of: .value, with: { (snapshot) in

                guard let object = snapshot.value as? [String: Any] else { return }

                do {

                    let opponent = try Opponent.init(json: object)

                    self.delegate?.manager(self, didGetOpponent: opponent)

                } catch let error {

                    // TODO: Error handling
                    print(error.localizedDescription)

                }

            })

        })

    }

    func addToChatPool() {

    }

    func removeFromChatPool() {

    }

}
