//
//  QBManager.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/28.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC

class QBManager {

    func logIn(withEmail email: String, withPassword password: String) {

        QBRequest.logIn(withUserEmail: email, password: password, successBlock: { (response, _) in

            // MARK: User logged in with Quickblox successfully.

        }) { (response) in

            // TODO: User failed to loggin.

            let error = response.error?.error

            print(error?.localizedDescription)

        }

    }

    func signUp(withEmail email: String, withPassword password: String) -> Int {

        var signUpUser = QBUUser()
        signUpUser.email = email
        signUpUser.password = password

        QBRequest.signUp(signUpUser, successBlock: {(response, user) in

            // MARK: User signed up a new account on Quickblox successfully.

            print("~~~~~~~~~~~~~~~~", response, "~~~~~~~~~~~~~~``", user)

            signUpUser = user!

        }) { (response) in

            // TODO: User failed to sign up a new account.

            let error = response.error?.error

            print(error?.localizedDescription)

        }

        return Int(signUpUser.id)

    }

}
