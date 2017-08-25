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

        guard let user = Auth.auth().currentUser else { return true }

        SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Fetch_Data", comment: ""))

        QBManager.shared.logIn(withEmail: user.email!, withPassword: user.uid)

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        FirebaseManager().removeAllObserver()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        if QBChat.instance().isConnected == true {

            //swiftlint:disable force_cast
            let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController

            mainTabVC.selectedIndex = 2

            AppDelegate.shared.window?.rootViewController = mainTabVC

        } else {

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Fetch_Data", comment: ""))

            guard let user = Auth.auth().currentUser else {

                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")

                AppDelegate.shared.window?.rootViewController = loginVC

                UserManager.shared.currentUser = nil

                return

            }

            QBManager.shared.logIn(withEmail: user.email!, withPassword: user.uid)

        }

    }

}
