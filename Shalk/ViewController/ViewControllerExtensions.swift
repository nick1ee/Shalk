//
//  ViewControllerExtensions.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

extension UIViewController {

    func pushLoginMessage(title: String, message: String, handle: ((UIAlertAction) -> Void)?) {

        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        let alertAction = UIAlertAction.init(title: "OK", style: .default, handler: handle)

        alertController.addAction(alertAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func pushLogOutMessage(handle: ((UIAlertAction) -> Void)?) {

        let alertController = UIAlertController.init(title: "Notification", message: "Do you want to log out this account?", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Confirm", style: .default, handler: handle)

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func receivedEndCallwithFriendRequest(withInfo info: [String: String]) {

        let alertController = UIAlertController.init(title: "Send a friend request?", message: "If you enjoy the time with \(UserManager.shared.opponent?.name ?? ""), send a friend request!", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Send", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = true

            self.presentedViewController?.dismiss(animated: true, completion: nil)

            QBManager.shared.leaveChannel()

            if info["sendRequest"] == "yes" && UserManager.shared.isSendingFriendRequest! {

                FirebaseManager().addFriend(withOpponent: UserManager.shared.opponent!)

            }

            UserManager.shared.isConnected = false

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = false

            self.presentedViewController?.dismiss(animated: true, completion: nil)

            QBManager.shared.leaveChannel()

            UserManager.shared.isConnected = false

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.presentedViewController?.present(alertController, animated: true, completion: nil)

    }

    func endCallWithFriendRequest() {

        let alertController = UIAlertController.init(title: "Send a friend request?", message: "If you enjoy the time with \(UserManager.shared.opponent?.name ?? ""), send a friend request!", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Send", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = true

            self.dismiss(animated: true, completion: nil)

            QBManager.shared.leaveChannel()

            UserManager.shared.isConnected = false

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = false

            self.dismiss(animated: true, completion: nil)

            QBManager.shared.leaveChannel()

            UserManager.shared.isConnected = false

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func startAudioCall(uid: String, name: String) {

        let alertController = UIAlertController.init(title: "Audio Call", message: "Do you want to start an audio call with \(name)?", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Confirm", style: .default) { (_) in

            FirebaseManager().fetchUserProfile(withUid: uid, type: .opponent, call: .audio)

            self.performSegue(withIdentifier: "audioCall", sender: nil)

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func startVideoCall(uid: String, name: String) {

        let alertController = UIAlertController.init(title: "Video Call", message: "Do you want to start an video call with \(name)?", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Confirm", style: .default) { (_) in

            FirebaseManager().fetchUserProfile(withUid: uid, type: .opponent, call: .video)

            self.performSegue(withIdentifier: "videoCall", sender: nil)

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

}
