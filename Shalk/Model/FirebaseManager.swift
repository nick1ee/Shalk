//
//  FirebaseManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Firebase
import FirebaseStorage
import SVProgressHUD

class FirebaseManager {

    weak var friendDelegate: FirebaseManagerFriendDelegate?

    weak var chatRoomDelegate: FirebaseManagerChatRoomDelegate?

    weak var chatHistroyDelegate: FirebaseManagerChatHistoryDelegate?

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

            if user != nil {

                // MARK: User Signed in Firebase successfully, start sign in with Quickblox.

                QBManager().logIn(withEmail: email, withPassword: pwd)

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

            QBManager().signUp(name: name, uid: okUser.uid, withEmail: email, withPassword: pwd)

                self.logIn(withEmail: email, withPassword: pwd)

            }

        }

    func registerProfile(uid: String, userDict: [String: String]) {

        ref?.child("users").child(uid).setValue(userDict)

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

    func updateUserProfile(withName name: String, withIntro intro: String) {

        guard let user = UserManager.shared.currentUser else { return }

        self.ref?.child("users").child(user.uid).child("name").setValue(name)

        if intro == "" {

            self.ref?.child("users").child(user.uid).child("intro").setValue("null")

        } else {

            self.ref?.child("users").child(user.uid).child("intro").setValue(intro)

        }

    }

    func uploadImage(withData data: Data) {

        let metaData = StorageMetadata()

        guard let user = UserManager.shared.currentUser else { return }

        metaData.contentType = "image/jpeg"

        storageRef.child("userImage").child(user.uid).putData(data, metadata: metaData) { (metadata, error) in

            if error != nil {

                // MARK: Failed to upload image.

                UIAlertController(error: error!).show()

                return

            }

            // MARK: Upload image successfully, and updated user image url.

            guard let imageUrlString = metadata?.downloadURL()?.absoluteString else { return }

            self.ref?.child("users").child(user.uid).child("imageUrl").setValue(imageUrlString)

        }

    }

    func fetchMyProfile(completion: @escaping () -> Void) {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        ref?.child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in

        guard let object = snapshot.value as? [String: Any] else { return }

        do {

            let user = try User.init(json: object)

            UserManager.shared.currentUser = user

            completion()

        } catch let error {

            UIAlertController(error: error).show()

            }

        })

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

                        self.userManager.startAudioCall()

                        break

                    case .video:

                        self.userManager.startVideoCall()

                        break

                    case .none:

                        break

                    }

                }

            } catch let error {

                // MARK: Failed to fetch user profile
                UIAlertController(error: error).show()
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

            for roomkey in object.keys {

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

                    // MARK: Failed to fetch channel.

                    UIAlertController(error: error).show()
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

//        userManager.roomKey = nil
//
//        userManager.language = nil

    }

    func checkFriendRequest() {

        guard let roomId = userManager.roomKey else {
            
            print("could not get room key")
            
            return
        
        }

        ref?.child("friendRequest").observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.hasChild(roomId) {

                // MARK: We are friends now, update both data.

                guard
                    let myUid = UserManager.shared.currentUser?.uid,
                    let language = UserManager.shared.language,
                    let opponent = UserManager.shared.opponent else {

                        print("error is here!")

                        return

                }

                self.ref?.child("friendList").child(myUid).updateChildValues([opponent.uid: language])

                self.ref?.child("friendList").child(opponent.uid).updateChildValues([myUid: language])

            } else {

                // MARK: Add myself into the queue.

                self.ref?.child("friendRequest").setValue([roomId: true])

            }
            
            QBManager.shared.handUpCall()

        })

    }

//    func addFriend(withOpponent opponent: User) {
//
//        guard let myUid = userManager.currentUser?.uid, let language = userManager.language else { return }
//
//        ref?.child("friendList").child(myUid).updateChildValues([opponent.uid: language])
//
//        ref?.child("friendList").child(opponent.uid).updateChildValues([myUid: language])
//
//    }

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

                // MARK: Failed to fetch friend info.
                UIAlertController(error: error).show()

            }

        })

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

                // MARK: Failed to fetch the list of chat rooms.
                UIAlertController(error: error).show()

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

                // MARK: Failed to fetch hcat histroy
                UIAlertController(error: error).show()

            }

            self.chatHistroyDelegate?.manager(self, didGetMessages: messages)

        })

    }

}
