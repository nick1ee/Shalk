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

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        guard let userToken = UserManager.shared.restore() else { return }

        // MARK: Fetched token successfully, log in directly.
        UserManager.shared.logIn(withEmail: userToken["email"]!, withPassword: userToken["password"]!)

        SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Fetch_Data", comment: ""))

    }

}
