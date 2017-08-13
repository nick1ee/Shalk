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

enum LanguageType: String {

    case english = "English"

    case chinese = "Chinese"

    case japanese = "Japanese"

    case korean = "Korean"
}

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

    func registerProfile(uid: String, userDict: [String: String]) {

        ref?.child("users").child(uid).setValue(userDict)

    }

    func removeAllObserver() {

        ref?.removeAllObservers()

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

    func fetchOpponentInfo(withUid uid: String, call: CallType) {

        ref?.child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in

            guard let object = snapshot.value as? [String: Any] else { return }

            do {

                let user = try User.init(json: object)

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

            } catch let error {

                // MARK: Failed to fetch user profile
                UIAlertController(error: error).show()
            }

        })

    }

    func fetchMyProfile(completion: @escaping () -> Void) {

        guard let userId = Auth.auth().currentUser?.uid else { return }

        ref?.child("users").child(userId).observeSingleEvent(of: .value, with: {(snapshot) in

            guard let object = snapshot.value as? [String: Any] else { return }

            do {

                let user = try User.init(json: object)

                UserManager.shared.currentUser = user

                DispatchQueue.main.async {

                    completion()

                }

            } catch let error {

                // MARK: Failed to fetch user profile
                UIAlertController(error: error).show()
            }

        })

    }

    func fetchChannel() {

        guard let language = UserManager.shared.language else { return }

        ref?.child("channels").child(language).queryOrdered(byChild: "isLocked").queryEqual(toValue: false).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value as? [String: Any] else {

                // MARK: No online rooms, create a new one.

                self.createNewChannel(withLanguage: language)

                return

            }

            do {

                // MARK: Find an available to join

                let channel = try AudioChannel.init(json: Array(object.values)[0])

                UserManager.shared.roomKey = channel.roomID

                self.updateChannel()

                self.fetchOpponentInfo(withUid: channel.owner, call: .audio)

                return

            } catch let error {

                // MARK: Failed to fetch channel.

                UIAlertController(error: error).show()
            }

        })

    }

    func createNewChannel(withLanguage language: String) {

        // MARK: No channel online.

        guard let uid = Auth.auth().currentUser?.uid, let roomId = ref?.childByAutoId().key else { return }

        let newChannel = AudioChannel.init(roomID: roomId, owner: uid)

        UserManager.shared.roomKey = roomId

        self.ref?.child("channels").child(language).child(roomId).setValue(newChannel.toDictionary())

    }

    func updateChannel() {

        guard
            let uid = userManager.currentUser?.uid,
            let roomId = userManager.roomKey,
            let lang = userManager.language else { return }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isLocked": true])

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["participant": uid])

    }

    func closeChannel() {

        guard let roomId = userManager.roomKey, let lang = userManager.language else { return }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isFinished": true, "isLocked": true])

        UserManager.shared.roomKey = nil

        UserManager.shared.language = nil

    }

    func leaveChannel() {

        guard
            let roomId = userManager.roomKey,
            let lang = userManager.language else { return }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isLocked": true, "isFinished": true])

    }

    func checkFriendRequest() {

        guard let roomId = userManager.roomKey else { return }

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

                let formatter = DateFormatter()

                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

                let timestamp = formatter.string(from: Date())

            self.ref?.child("friendList").child(myUid).child(language).updateChildValues([opponent.uid: timestamp])

                self.ref?.child("friendList").child(opponent.uid).child(language).updateChildValues([myUid: timestamp])

                UserManager.shared.closeChannel()

            } else {

                // MARK: Add myself into the queue.

                self.ref?.child("friendRequest").child(roomId).setValue(true)

                UserManager.shared.closeChannel()

            }

        })

    }

    func fetchFriendList(languageType: LanguageType) {

        guard let uid = Auth.auth().currentUser?.uid else { return }

        ref?.child("friendList").child(uid).child(languageType.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let friendList = snapshot.value as? [String: Any] else { return }

            let friendsUids = Array(friendList.keys)

            self.fetchFriendInfo(withFriends: friendsUids, languageType: languageType)

        })

    }

    func fetchFriendInfo(withFriends friendUids: [String], languageType: LanguageType) {

        for friendUid in friendUids {

            ref?.child("users").child(friendUid).observeSingleEvent(of: .value, with: { (snapshot) in

                guard let object = snapshot.value else { return }

                do {

                    let user = try User.init(json: object)

                    var friends = UserManager.shared.friends.filter { $0.uid != user.uid }

                    friends.append(user)

                    UserManager.shared.friends = friends

                    DispatchQueue.main.async {

                        self.friendDelegate?.manager(self, didGetFriend: user, byType: languageType)

                    }

                } catch let error {

                    // MARK: Failed to fetch friend info.
                    UIAlertController(error: error).show()

                }

            })

        }

    }

}

// MARK: Update user profile functions
extension FirebaseManager {

    func updateUserName(name: String) {

        guard let user = UserManager.shared.currentUser else { return }

        ref?.child("users").child(user.uid).child("name").setValue(name)

    }

    func updateUserIntro(intro: String) {

        guard let user = UserManager.shared.currentUser else { return }

        ref?.child("users").child(user.uid).child("intro").setValue(intro)

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

            UserManager.shared.currentUser?.imageUrl = imageUrlString

        }

    }

}

// MARK: Real-time chat functions
extension FirebaseManager {

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

            guard let obejct = snapshot.value as? [String: Any] else { return }

            do {

                let room = try ChatRoom.init(json: obejct)

                rooms.append(room)

            } catch let error {

                // MARK: Failed to fetch the list of chat rooms.
                UIAlertController(error: error).show()

            }

            self.userManager.chatRooms = rooms

            DispatchQueue.main.async {

                self.chatRoomDelegate?.manager(self, didGetChatRooms: rooms)

            }

        })

    }

    func updateChatRoom() {

        guard let myUid = Auth.auth().currentUser?.uid else { return }

        let roomId = UserManager.shared.chatRoomId

        ref?.child("chatRoomList").child(myUid).child(roomId).updateChildValues(["isRead": true])

    }

    func sendMessage(text: String) {

        let roomId = userManager.chatRoomId

        guard
            let messageId = ref?.childByAutoId().key,
            let myUid = userManager.currentUser?.uid,
            let opponentUid = userManager.opponent?.uid else { return }

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        let newMessage = Message.init(text: text)

        ref?.child("chatHistory").child(roomId).child(messageId).updateChildValues(newMessage.toDictionary())

    ref?.child("chatRoomList").child(myUid).child(roomId).updateChildValues(["latestMessage": text, "latestMessageTime": timestamp])

    ref?.child("chatRoomList").child(opponentUid).child(roomId).updateChildValues(["latestMessage": text, "latestMessageTime": timestamp, "isRead": false])

    }

    func fetchChatHistory(completion: @escaping ([Message]) -> Void) {

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

            completion(messages)

        })

    }

}
