//
//  FirebaseManagerProtocols.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/9.
//  Copyright © 2017年 nicklee. All rights reserved.
//

//protocol FirebaseManagerFriendDelegate: class {
//
//    func manager (_ manager: FirebaseManager, didGetFriend friend: User, by type: FriendType)
//
//    func manager (_ manager: FirebaseManager, didGetError error: Error)
//
//}

protocol FirebaseManagerChatRoomDelegate: class {

    func manager (_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom])

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

enum CallType {

    case audio, video, none

}

//swiftlint:disable identifier_name
enum FriendType: String {

    case me

    case friend = "true"

}
