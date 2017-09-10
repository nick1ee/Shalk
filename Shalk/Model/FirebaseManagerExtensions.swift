//
//  FirebaseManagerExtensions.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/14.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: FirebaseMAnagerExtensions

import Foundation
import Firebase
import FirebaseStorage
import Crashlytics

// MARK: Pairing Mechanism

extension FirebaseManager {

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

                self.fetchFriendInfo(
                    channel.owner,
                    completion: { (user) in

                    UserManager.shared.opponent = user

                    UserManager.shared.startAudioCall()

                })

            } catch let error {

                // MARK: Failed to fetch channel.
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["info": "Fetch_Channel_Error"])

                UIAlertController(error: error).show()
            }

        })

    }

    func createNewChannel(withLanguage language: String) {

        // MARK: No channel online.

        guard
            let uid = Auth.auth().currentUser?.uid,
            let roomId = ref?.childByAutoId().key
            else {

                return

        }

        let newChannel = AudioChannel(
            roomID: roomId,
            owner: uid
        )

        UserManager.shared.roomKey = roomId

        ref?.child("channels").child(language).child(roomId).setValue(newChannel.toDictionary())

    }

    func updateChannel() {

        guard
            let uid = UserManager.shared.currentUser?.uid,
            let roomId = UserManager.shared.roomKey,
            let lang = UserManager.shared.language
            else {

                return

        }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isLocked": true])

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["participant": uid])

    }

    func closeChannel() {

        guard
            let roomId = UserManager.shared.roomKey,
            let lang = UserManager.shared.language
            else {

                return

        }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isFinished": true, "isLocked": true])

        UserManager.shared.language = nil

    }

    func leaveChannel() {

        guard
            let roomId = UserManager.shared.roomKey,
            let lang = UserManager.shared.language
            else {

                return

        }

        ref?.child("channels").child(lang).child(roomId).updateChildValues(["isLocked": true, "isFinished": true])

    }

}

// MARK: Friends Mechanism

extension FirebaseManager {

    func checkFriendRequest() {

        if let roomId = UserManager.shared.roomKey {

            ref?.child("friendRequest").observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.hasChild(roomId) {

                    // MARK: We are friends now, update both data.

                    guard
                        let myUid = UserManager.shared.currentUser?.uid,
                        let opponent = UserManager.shared.opponent
                        else {

                            return

                    }

                    self.ref?.child("friendList").child(myUid).updateChildValues([opponent.uid: "true"])

                    self.ref?.child("friendList").child(opponent.uid).updateChildValues([myUid: "true"])

                } else {

                    // MARK: Send friend request.

                    self.ref?.child("friendRequest").child(roomId).setValue(true)

                }

                self.closeChannel()

            })

        }

    }

    func fetchFriendList(completion: @escaping (User) -> Void) {

        if let uid = Auth.auth().currentUser?.uid {

            ref?.child("friendList").child(uid).observe(.value, with: { (snapshot) in

                UserManager.shared.friends = []

                guard let friendList = snapshot.value as? [String: String] else { return }

                for friend in friendList {

                    let friendUid = friend.key

                    self.fetchFriendInfo(
                        friendUid,
                        completion: completion
                    )

                }

            })

        }

    }

    func fetchFriendInfo(_ friendUid: String, completion: @escaping (User) -> Void) {

        ref?.child("users").child(friendUid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let object = snapshot.value else { return }

            do {

                let user = try User.init(json: object)

                DispatchQueue.main.async {

                    completion(user)

                }

            } catch let error {

                // MARK: Failed to fetch friend info.

                Crashlytics.sharedInstance().recordError(
                    error,
                    withAdditionalUserInfo: ["info": "Fetch_FriendInfo_Error"]
                )

                UIAlertController(error: error).show()

            }

        })

    }

    func checkFriendStatus(_ friendUid: String, completion: @escaping (Bool) -> Void) {

        guard let myUid = Auth.auth().currentUser?.uid else { return }

        ref?.child("friendList").child(myUid).child(friendUid).observeSingleEvent(of: .value, with: { (snapshot) in

            guard let status = snapshot.value as? String else { return }

            if status == "true" {

                completion(true)

            } else {

                completion(false)

            }

        })

    }

}

// MARK: User Profile

extension FirebaseManager {

    func registerProfile(uid: String, userDict: [String: String]) {

        ref?.child("users").child(uid).setValue(userDict)

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

                Crashlytics.sharedInstance().recordError(
                    error,
                    withAdditionalUserInfo: ["info": "Fetch_MyProfile_Error"]
                )

                UIAlertController(error: error).show()
            }

        })

    }

    func updateUserName(name: String) {

        if let user = UserManager.shared.currentUser {

            ref?.child("users").child(user.uid).child("name").setValue(name)

        }

    }

    func updateUserIntro(intro: String) {

        if let user = UserManager.shared.currentUser {

            ref?.child("users").child(user.uid).child("intro").setValue(intro)

        }

    }

    func uploadImage(withData data: Data) {

        let metaData = StorageMetadata()

        guard let user = UserManager.shared.currentUser else { return }

        metaData.contentType = "image/jpeg"

        storageRef.child("userImage").child(user.uid).putData(data, metadata: metaData) { (metadata, error) in

            if let error = error {

                // MARK: Failed to upload image.

                UIAlertController(error: error).show()

                return

            }

            // MARK: Upload image successfully, and updated user image url.

            if let imageUrlString = metadata?.downloadURL()?.absoluteString {

                self.ref?.child("users").child(user.uid).child("imageUrl").setValue(imageUrlString)

                UserManager.shared.currentUser?.imageUrl = imageUrlString

            }

        }

    }

}

// MARK: Real-Time Communication

extension FirebaseManager {

    func createChatRoom(to opponent: User) {

        guard
            let myUid = Auth.auth().currentUser?.uid,
            let roomId = ref?.childByAutoId().key
            else {

                return

        }

        let room = ChatRoom(
            roomId: roomId,
            opponent: opponent
        )

        ref?.child("chatRoomList").child(myUid).child(roomId).setValue(room.toDictionary())

        ref?.child("chatRoomList").child(opponent.uid).child(roomId).setValue(room.toDictionary())

        ref?.child("chatHistory").child(roomId).child("init").setValue(Message.init(text: "").toDictionary())

        UserManager.shared.chatRoomId = roomId

    }

    func fetchChatRoomList() {

        guard let myUid = Auth.auth().currentUser?.uid else { return }

        handle = ref?.child("chatRoomList").child(myUid).observe(.value, with: { (snapshot) in

            UserManager.shared.chatRooms = []

            var rooms: [ChatRoom] = []

            guard let roomList = snapshot.value as? [String: Any] else { return }

            for object in roomList {

                do {

                    let room = try ChatRoom(json: object.value)

                    rooms.append(room)

                } catch let error {

                    // MARK: Failed to fetch the list of chat rooms.

                    Crashlytics.sharedInstance().recordError(
                        error,
                        withAdditionalUserInfo: ["info": "Fetch_ChatRoom_Error"]
                    )

                    UIAlertController(error: error).show()

                }

            }

            let sortedRooms = rooms.sorted(by: { (room1, room2) -> Bool in

                let formatter = DateFormatter()

                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

                let room1Time = formatter.date(from: room1.latestMessageTime)

                let room2Time = formatter.date(from: room2.latestMessageTime)

                return room1Time!.compare(room2Time!) == .orderedDescending

            })

            UserManager.shared.chatRooms = sortedRooms

            DispatchQueue.main.async {

                self.chatRoomDelegate?.manager(
                    self,
                    didGetChatRooms: sortedRooms
                )

            }

        })

    }

    func updateChatRoom() {

        if let myUid = Auth.auth().currentUser?.uid {

            let roomId = UserManager.shared.chatRoomId

            ref?.child("chatRoomList").child(myUid).child(roomId).updateChildValues(["isRead": true])

        }

    }

    func sendMessage(text: String) {

        let roomId = UserManager.shared.chatRoomId

        guard
            let messageId = ref?.childByAutoId().key,
            let myUid = UserManager.shared.currentUser?.uid,
            let opponentUid = UserManager.shared.opponent?.uid
            else {

                return

        }

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        let newMessage = Message.init(text: text)

        ref?.child("chatHistory").child(roomId).child(messageId).updateChildValues(newMessage.toDictionary())

        ref?.child("chatRoomList").child(myUid).child(roomId).updateChildValues(["latestMessage": text, "latestMessageTime": timestamp])

        ref?.child("chatRoomList").child(opponentUid).child(roomId).updateChildValues(["latestMessage": text, "latestMessageTime": timestamp, "isRead": false])

    }

    func sendCallRecord(_ callType: CallType, duration: String, roomId: String) {

        if let messageId = ref?.childByAutoId().key {

            let formatter = DateFormatter()

            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

            let timestamp = formatter.string(from: Date())

            let newMessage = Message(
                text: duration,
                senderId: callType.rawValue,
                time: timestamp
            )

            ref?.child("chatHistory").child(roomId).child(messageId).updateChildValues(newMessage.toDictionary())

        }

    }

    func generateAutoId() -> String {

        if let autoId = ref?.childByAutoId().key {

            return autoId

        }

        return "123456789"

    }

    func fetchChatHistory(completion: @escaping ([Message]) -> Void) {

        var messages: [Message] = []

        let roomId = UserManager.shared.chatRoomId

        handle = ref?.child("chatHistory").child(roomId).observe(.childAdded, with: { (snapshot) in

            guard let object = snapshot.value as? [String: String] else { return }

            do {

                let message = try Message.init(json: object)

                messages.append(message)

            } catch let error {

                // MARK: Failed to fetch hcat histroy

                Crashlytics.sharedInstance().recordError(
                    error,
                    withAdditionalUserInfo: ["info": "Fetch_ChatHistory_Error"]
                )

                UIAlertController(error: error).show()

            }

            DispatchQueue.main.async {

                completion(messages)

            }

        })

    }

}

// MARK: Block and Report

extension FirebaseManager {

    func blockFriend(completion: @escaping () -> Void) {

        guard
            let myUid = UserManager.shared.currentUser?.uid,
            let friendUid = UserManager.shared.opponent?.uid
            else {

                return

        }

        let roomId = UserManager.shared.chatRoomId

        ref?.child("friendList").child(myUid).child(friendUid).removeValue()

        ref?.child("chatRoomList").child(myUid).child(roomId).removeValue()

        ref?.child("friendList").child(friendUid).child(myUid).setValue("Blocked")

        DispatchQueue.main.async {

            completion()

        }

    }

    func reportFriend(_ reason: String, completion: @escaping () -> Void) {

        guard
            let myUid = Auth.auth().currentUser?.uid,
            let opponentUid = UserManager.shared.opponent?.uid,
            let reportId = ref?.childByAutoId().key
            else {

                return

        }

        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        let report = [

            "ausiveUser": opponentUid,
            "prosecutor": myUid,
            "reason": reason,
            "time": timestamp,
            "reportId": reportId

        ]

        ref?.child("ReportUser").child(reportId).updateChildValues(report)

        DispatchQueue.main.async {

            completion()

        }

    }

}

// MARK: Remove Observer

extension FirebaseManager {

    func removeAllObserver() {

        ref?.removeAllObservers()

    }

}

// MARK: Analystic.

extension FirebaseManager {

    func logEvent(_ eventName: String) {

        Analytics.logEvent(eventName, parameters: nil)

    }

}
