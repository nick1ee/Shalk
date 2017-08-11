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

    func receivedEndCallwithFriendRequest() {

        let alertController = UIAlertController.init(title: "Send a friend request?", message: "If you enjoy the time with \(UserManager.shared.opponent?.name ?? ""), send a friend request!", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Send", style: .default) { (_) in

            FirebaseManager().checkFriendRequest()

            self.presentedViewController?.dismiss(animated: true, completion: nil)

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.closeChannel()

            self.presentedViewController?.dismiss(animated: true, completion: nil)

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.presentedViewController?.present(alertController, animated: true, completion: nil)

    }

    func endCallWithFriendRequest() {

        let alertController = UIAlertController.init(title: "Send a friend request?", message: "If you enjoy the time with \(UserManager.shared.opponent?.name ?? ""), send a friend request!", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Send", style: .default) { (_) in

            FirebaseManager().checkFriendRequest()

            UserManager.shared.closeChannel()

            self.dismiss(animated: true, completion: nil)

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.closeChannel()

            self.dismiss(animated: true, completion: nil)

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func startAudioCall(uid: String, name: String) {

        let alertController = UIAlertController.init(title: "Audio Call", message: "Do you want to start an audio call with \(name)?", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Confirm", style: .default) { (_) in

            FirebaseManager().fetchUserProfile(withUid: uid, call: .audio)

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

            self.performSegue(withIdentifier: "videoCall", sender: nil)

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func pushNoRespondMessage() {

        guard let opponent = UserManager.shared.opponent else { return }

        let alertController = UIAlertController.init(title: "No Answer", message: "\(opponent.name) did not answer the call.", preferredStyle: .alert)

        alertController.addAction(title: "OK", style: .default, isEnabled: true) { (_) in

            self.dismiss(animated: true, completion: nil)
        }

        self.present(alertController, animated: true, completion: nil)

    }

}
