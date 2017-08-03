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

    func manager (_ manager: FirebaseManager, didGetList friends: [Friend], byLanguage: String)

    func manager (_ manager: FirebaseManager, didGetError error: Error)

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

            self.userManager.currentUser = User(name: name,

                                            uid: okUser.uid,

                                            email: email,

                                            quickbloxID: "",

                                            imageURL: "null",

                                            intro: "null",

                                            friends: ["default": "null"],
            
                                            chats: ["default": "null"])

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

                self.userManager.currentUser = user

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)
            }

        })

    }

    func fetchChannels(withLang language: String) {

        ref?.child("channels").child(language).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value as? [String: Any] else {

                // MARK: No online rooms, create a new one.

                self.createNewChannel(withLanguage: language)

                return

            }

            let roomkeys = object.keys

            for roomkey in roomkeys {

                do {

                    let room = try Room.init(json: object[roomkey] as Any)

                    if room.isLocked == false && room.isFinished == false {

                        // MARK: Find an available to join

                        self.userManager.roomKey = roomkey

                        self.userManager.language = language

                        self.fetchOpponentData(withRoom: room)

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

    func fetchOpponentData(withRoom room: Room) {

        ref?.child("users").child(room.owner).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value as? [String: Any] else { return }

            do {

                // MARK: Init the opponent and get started to join the call.

                let opponent = try Opponent.init(json: object)

                self.userManager.opponent = opponent

                self.userManager.joinChannel()

            } catch let error {

                // TODO: Error handling

                print(error.localizedDescription)

            }

        })

    }

    func createNewChannel(withLanguage language: String) {

        // MARK: No rooms online.

        guard let uid = Auth.auth().currentUser?.uid, let id = ref?.childByAutoId().key else { return }

        let roomInfo: [String: Any] = ["roomID": id, "participant": "null", "owner": uid, "isLocked": false, "isFinished": false]

        userManager.roomKey = id

        userManager.language = language

        self.ref?.child("channels").child(language).child(id).setValue(roomInfo)

    }

    func removeFromChatPool(withLanguage language: String) {

        ref?.child("chatPool").child(language).setValue(nil)

    }

    func updateChannel(withRoomKey key: String, withLang language: String) {

        guard let uid = userManager.currentUser?.uid else { return }

        ref?.child("channels").child(language).child(key).updateChildValues(["isLocked": true])

        ref?.child("channels").child(language).child(key).updateChildValues(["participant": uid])

    }

    func closeChannel(withRoomKey key: String, withLang language: String) {

        ref?.child("channels").child(language).child(key).updateChildValues(["isFinished": true])

    }

    func addIntoFriendList(withOpponent opponent: Opponent) {

        guard let myUid = userManager.currentUser?.uid, let language = userManager.language else { return }

        ref?.child("users").child(myUid).child("friendList").updateChildValues([opponent.uid: language])
        ref?.child("users").child(opponent.uid).child("friendList").updateChildValues([myUid: language])

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

    }

    func fetchFriendsInfo(withUsers uidArray: [String], withLang language: String) {

        var friendsByLanguage: [Friend] = []

        for uid in uidArray {

            self.ref?.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

                guard let object = snapshot.value else { return }

                do {

                    let friend = try Friend.init(json: object)

                    friendsByLanguage.append(friend)

                } catch let error {

                    // TODO: Error handling
                    print(error.localizedDescription)

                }

                self.delegate?.manager(self, didGetList: friendsByLanguage, byLanguage: language)

            })

        }

    }

}
