////
////  Call.swift
////  Shalk
////
////  Created by Nick Lee on 2017/8/23.
////  Copyright © 2017年 nicklee. All rights reserved.
////
//
//import UIKit
//
//struct Call {
//
//    let hostId: String
//
//    let guestId: String
//
//    let callType: String
//
//    let duration: String
//
//    let chatRoomId: String
//
//}
//
//extension Call {
//
//    typealias CallObject = [String: String]
//
//    enum ParseCallInfoError: Error {
//
//        case inValidCallObject, missingHostId, missingGuestId, missingCallType, missingDuration, missingChatRoomId
//
//    }
//
//    struct Schema {
//
//        static let hostId = "hostId"
//
//        static let gusetId = "guestId"
//
//        static let callType = "callType"
//
//        static let duration = "duration"
//
//        static let chatRoomId = "roomId"
//
//    }
//
//    init(object: Any) throws {
//
//        guard let callinfo = object as? CallObject else {
//
//            throw ParseCallInfoError.inValidCallObject
//
//        }
//
//        guard let hostId = callinfo[Schema.hostId] else {
//
//            throw ParseCallInfoError.missingHostId
//
//        }
//
//        self.hostId = hostId
//
//        guard let guestId = callinfo[Schema.gusetId] else {
//
//            throw ParseCallInfoError.missingGuestId
//
//        }
//
//        self.guestId = guestId
//
//        guard let callType = callinfo[Schema.callType] else {
//
//            throw ParseCallInfoError.missingCallType
//
//        }
//
//        self.callType = callType
//
//        guard let duration = callinfo[Schema.duration] else {
//
//            throw ParseCallInfoError.missingDuration
//
//        }
//
//        self.duration = duration
//
//        guard let roomId = callinfo[Schema.chatRoomId] else {
//
//            throw ParseCallInfoError.missingChatRoomId
//
//        }
//
//        self.chatRoomId = roomId
//
//    }
//
//    init(_ myUid: String, to friendUid: String, type: String, duration: String, roomId: String) {
//
//        self.hostId = myUid
//
//        self.guestId = friendUid
//
//        self.callType = type
//
//        self.duration = duration
//
//        self.chatRoomId = roomId
//
//    }
//
//    func toDictionary() -> CallObject {
//
//        let callinfo: CallObject = [Schema.hostId: self.hostId,
//
//                                    Schema.gusetId: self.guestId,
//
//                                    Schema.callType: self.callType,
//
//                                    Schema.duration: self.duration,
//
//                                    Schema.chatRoomId: self.chatRoomId]
//
//        return callinfo
//
//    }
//
//}
