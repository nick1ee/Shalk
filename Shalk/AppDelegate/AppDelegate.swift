//
//  AppDelegate.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Firebase
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.statusBarStyle = .lightContent

        // MARK: Init Firebase
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])

        // MARK: Init Quickblox
        QBRTCClient.initializeRTC()

        QBSettings.setApplicationID(QBAppID)
        QBSettings.setAuthKey(QBAuthKey)
        QBSettings.setAuthSecret(QBAuthSecret)
        QBSettings.setAccountKey(QBAccountKey)

        QBSettings.enableXMPPLogging()

        guard let userToken = UserManager.shared.restore() else { return true }

        // MARK: Fetched token successfully, log in directly.
        UserManager.shared.logIn(withEmail: userToken["email"]!, withPassword: userToken["password"]!)

        SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Fetch_Data", comment: ""))

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        FirebaseManager().removeAllObserver()

//        QBChat.instance().disconnect(completionBlock: nil)

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        guard let userToken = UserManager.shared.restore() else { return }

        SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Fetch_Data", comment: ""))
//
//        // MARK: Fetched token successfully, log in directly.
//        UserManager.shared.logIn(withEmail: userToken["email"]!, withPassword: userToken["password"]!)

        if QBChat.instance().isConnected == true {

            print("yes")

        } else {

            print("false")

        }

        let user = QBUUser()
        user.email = userToken["email"]
        user.password = userToken["password"]

        let qbuser = QBChat.instance().currentUser()

        print(qbuser)

        QBChat.instance().connect(with: user) { (error) in

            if error == nil {

                SVProgressHUD.dismiss()

            } else {

                print(user, error?.localizedDescription)

                SVProgressHUD.dismiss()

                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")

                AppDelegate.shared.window?.rootViewController = loginVC

            }

        }

    }

}
