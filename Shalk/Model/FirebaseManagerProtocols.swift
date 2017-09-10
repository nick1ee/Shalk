//
//  FirebaseManagerProtocols.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/9.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - FirebaseManagerChatRoomDelegate

protocol FirebaseManagerChatRoomDelegate: class {

    func manager (_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom])

    func manager (_ manager: FirebaseManager, didGetError error: Error)

}

// MARK: - CallType

enum CallType: String {

    case audio = "Audio Call"

    case video = "Video Call"

    case none

}
