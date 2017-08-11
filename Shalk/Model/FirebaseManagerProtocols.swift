//
//  FirebaseManagerProtocols.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/9.
//  Copyright © 2017年 nicklee. All rights reserved.
//

protocol FirebaseManagerFriendDelegate: class {

    func manager (_ manager: FirebaseManager, didGetFriend friend: User, byType: LanguageType)

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

protocol FirebaseManagerChatRoomDelegate: class {

    func manager (_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom])

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

enum UserProfile {

    case myself, opponent

}

enum CallType {

    case audio, video, none

}
