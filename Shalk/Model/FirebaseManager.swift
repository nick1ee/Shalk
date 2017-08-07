//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseManagerFriendDelegate: class {

    func manager (_ manager: FirebaseManager, didGetFriend friend: User, byLanguage: String)

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

protocol FirebaseManagerChatRoomDelegate: class {

    func manager (_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom])

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

protocol FirebaseManagerChatHistoryDelegate: class {

    func manager (_ manager: FirebaseManager, didGetMessages messages: [Message])

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

enum UserProfile {

    case myself, opponent

}

enum CallType {

    case audio, video

}

class FirebaseManager {

    weak var friendDelegate: FirebaseManagerFriendDelegate?

    weak var chatRoomDelegate: FirebaseManagerChatRoomDelegate?

    weak var chatHistroyDelegate: FirebaseManagerChatHistoryDelegate?

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

                UserManager.shared.isFirebaseLogin = true

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

        do {

            try Auth.auth().signOut()

            QBManager().logOut()

        } catch let error {

            // TODO: Error handling
            print(error.localizedDescription)

        }

    }

    func fetchUserProfile(withUid uid: String, type: UserProfile, call: CallType) {

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

                    switch call {

                    case .audio:

                        print("PPPPPPPP", self.userManager.opponent)

                        self.userManager.startAudioCall()

                        break

                    case .video:

                        self.userManager.startVideoCall()

                        break

                    }

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

                        self.updateChannel(withRoomKey: roomkey, withLang: language)

                        self.fetchUserProfile(withUid: channel.owner, type: .opponent, call: .audio)

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

    func addFriend(withOpponent opponent: User) {

        guard let myUid = userManager.currentUser?.uid, let language = userManager.language else { return }

        ref?.child("friendList").child(myUid).updateChildValues([opponent.uid: language])

        ref?.child("friendList").child(opponent.uid).updateChildValues([myUid: language])

    }

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

        ref?.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value else { return }

            do {

                let user = try User.init(json: object)

                self.friendDelegate?.manager(self, didGetFriend: user, byLanguage: language)

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)

            }

        })

    }

    func startChat(to opponent: User) {

        ref?.child("")

    }

    func createChatRoom(to opponent: User) {

        guard
            let myUid = Auth.auth().currentUser?.uid,
            let roomId = ref?.childByAutoId().key else { return }

        let room = ChatRoom.init(roomId: roomId, opponent: opponent)

        ref?.child("chatRoomList").child(myUid).child(roomId).updateChildValues(room.toDictionary())

        ref?.child("chatRoomList").child(opponent.uid).child(roomId).updateChildValues(room.toDictionary())

        ref?.child("chatHistory").child(roomId).child("init").updateChildValues(Message.init(text: "").toDictionary())

        userManager.chatRoomId = roomId

    }

    func fetchChatRoomList() {

        var rooms: [ChatRoom] = []

        guard let myUid = Auth.auth().currentUser?.uid else { return }

        handle = ref?.child("chatRoomList").child(myUid).observe(.childAdded, with: { (snapshot) in

            guard let obejct = snapshot.value as? [String: String] else { return }

            do {

                let room = try ChatRoom.init(json: obejct)

                rooms.append(room)

            } catch let error {

                // TODO: Error handlng
                print(error.localizedDescription)

            }

            self.ref?.removeObserver(withHandle: self.handle!)

            self.userManager.chatRooms = rooms

            self.chatRoomDelegate?.manager(self, didGetChatRooms: rooms)

        })

    }

    func sendMessage(text: String) {

        let roomId = userManager.chatRoomId

        guard let messageId = ref?.childByAutoId().key else { return }

        let newMessage = Message.init(text: text)

        ref?.child("chatHistory").child(roomId).child(messageId).updateChildValues(newMessage.toDictionary())

    }

    func fetchChatHistory() {

        var messages: [Message] = []

        let roomId = userManager.chatRoomId

        handle = ref?.child("chatHistory").child(roomId).observe(.childAdded, with: { (snapshot) in

            guard let object = snapshot.value as? [String: String] else { return }

            do {

                let message = try Message.init(json: object)

                messages.append(message)

            } catch let error {

                // TODO: Error handling
                print(error.localizedDescription)

            }

//            self.ref?.removeObserver(withHandle: self.handle!)

            self.chatHistroyDelegate?.manager(self, didGetMessages: messages)

        })

    }

}
