//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseManagerDelegate: class {

    func manager (_ manager: FirebaseManager, didGetFriend friend: User, byLanguage: String)

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

enum UserProfile {

    case myself, opponent

}

class FirebaseManager {

    weak var delegate: FirebaseManagerDelegate?

    var ref: DatabaseReference? = Database.database().reference()

    var handle: DatabaseHandle?

    let userManager = UserManager.shared

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

                                            self.userManager.fetchUserData()

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

            let currentUser = User.init(name: name, uid: okUser.uid, email: email, quickbloxId: "", imageUrl: "null", intro: "null")

            self.userManager.currentUser = currentUser

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

    func fetchUserProfile(withUid uid: String, type: UserProfile) {

        ref?.child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in

            guard let object = snapshot.value as? [String: Any] else { return }

            do {

                let user = try User.init(json: object)

                switch type {

                case .myself:

                    self.userManager.currentUser = user

                    break

                case .opponent:

                    self.userManager.opponent = user

                    self.userManager.joinChannel()

                    break

                }

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)
            }

        })

    }

    func fetchChannel(withLang language: String) {

        ref?.child("channels").child(language).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value as? [String: Any] else {

                // MARK: No online rooms, create a new one.

                self.createNewChannel(withLanguage: language)

                return

            }

            let roomkeys = object.keys

            for roomkey in roomkeys {

                do {

                    let channel = try AudioChannel.init(json: object[roomkey] as Any)

                    if channel.isLocked == false && channel.isFinished == false {

                        // MARK: Find an available to join

                        self.userManager.roomKey = roomkey

                        self.userManager.language = language

                        self.fetchUserProfile(withUid: channel.owner, type: .opponent)

                        return

                    }

                } catch let error {

                    // TODO: Error handling

                    print(error.localizedDescription)
                }

            }

            // MARK: No available rooms, create a new one.

            self.createNewChannel(withLanguage: language)

        })

    }

    func createNewChannel(withLanguage language: String) {

        // MARK: No channel online.

        guard let uid = Auth.auth().currentUser?.uid, let roomId = ref?.childByAutoId().key else { return }

        let newChannel = AudioChannel.init(roomID: roomId, owner: uid)

        userManager.roomKey = roomId

        userManager.language = language

        self.ref?.child("channels").child(language).child(roomId).setValue(newChannel.toDictionary())

    }

    func updateChannel(withRoomKey key: String, withLang language: String) {

        guard let uid = userManager.currentUser?.uid else { return }

        ref?.child("channels").child(language).child(key).updateChildValues(["isLocked": true])

        ref?.child("channels").child(language).child(key).updateChildValues(["participant": uid])

    }

    func closeChannel(withRoomKey key: String, withLang language: String) {

        ref?.child("channels").child(language).child(key).updateChildValues(["isFinished": true])

    }

    func addIntoFriendList(withOpponent opponent: User) {

        guard let myUid = userManager.currentUser?.uid, let language = userManager.language else { return }

        ref?.child("friendList").child(myUid).updateChildValues([opponent.uid: language])

        ref?.child("friendList").child(opponent.uid).updateChildValues([myUid: language])

    }

    //        guard let roomId = ref?.childByAutoId().key, let messageId = ref?.childByAutoId().key else { return }
    //
    //        guard let time = Date().timeIntervalSince1970 as? Double else { return }
    //
    //        let messageDict: [String: Any] = ["id": messageId, "uid": "Admin", "message": "You are frineds now.", "time": time]
    //
    //        ref?.child("chats").child(roomId).child(messageId).setValue(messageDict)
    //
    //        ref?.child("users").child(myUid).child("chats").updateChildValues(["roomIdD": roomId])
    //        ref?.child("users").child(opponent.uid).child("chats").updateChildValues(["roomIdD": roomId])

    func fetchFriendList() {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        ref?.child("friendList").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            for object in snapshot.children {

                guard let userObject = object as? DataSnapshot else { return }

                let uid = userObject.key

                guard let language = userObject.value as? String else { return }

                self.fetchFriendInfo(withUser: uid, withLang: language)

            }

        })

    }

    func fetchFriendInfo(withUser uid: String, withLang language: String) {

        self.ref?.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value else { return }

            do {

                let user = try User.init(json: object)

                self.delegate?.manager(self, didGetFriend: user, byLanguage: language)

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)

            }

        })

    }

}
