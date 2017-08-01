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

    func pushLougOutMessage(title: String, message: String, handle: ((UIAlertAction) -> Void)?) {

        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: handle)

        let cancelAction = UIAlertAction.init(title: "OK", style: .default, handler: handle)

        alertController.addAction(okAction)

        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)

    }

    func receivedEndCallwithFriendRequest(withInfo info: [String: String]) {

        let alertController = UIAlertController.init(title: "Send a friend request?", message: "If you enjoy the time with \(UserManager.shared.opponent?.name ?? ""), send a friend request!", preferredStyle: .alert)

        let okAction = UIAlertAction.init(title: "Send", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = true

            self.presentedViewController?.dismiss(animated: true, completion: nil)

            QBManager.shared.hangUpCall()

            if info["sendRequest"] == "yes" && UserManager.shared.isSendingFriendRequest! {
                
                print("=======================================", UserManager.shared.isSendingFriendRequest)

                FirebaseManager().addIntoFriendList(withOpponent: UserManager.shared.opponent!)

            }

            UserManager.shared.isConnected = false

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = false

            self.presentedViewController?.dismiss(animated: true, completion: nil)

            QBManager.shared.hangUpCall()

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

            QBManager.shared.hangUpCall()

            UserManager.shared.isConnected = false

        }

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (_) in

            UserManager.shared.isSendingFriendRequest = false

            self.dismiss(animated: true, completion: nil)

            QBManager.shared.hangUpCall()

            UserManager.shared.isConnected = false

        }

        alertController.addAction(cancelAction)

        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)

    }

}
