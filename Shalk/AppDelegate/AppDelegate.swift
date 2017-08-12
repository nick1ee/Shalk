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
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.statusBarStyle = .lightContent

        // MARK: Init Firebase
        FirebaseApp.configure()

        // MARK: Init Quickblox
        QBRTCClient.initializeRTC()

        QBSettings.setApplicationID(QBAppID)
        QBSettings.setAuthKey(QBAuthKey)
        QBSettings.setAuthSecret(QBAuthSecret)
        QBSettings.setAccountKey(QBAccountKey)

        QBSettings.enableXMPPLogging()

        // MARK: Init IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
//        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        guard let userToken = UserManager.shared.restore() else { return true }

        // MARK: Fetched token successfully, log in directly.
        //swiftlint:disable force_cast
        UserManager.shared.logIn(withEmail: userToken["email"]!, withPassword: userToken["password"]!)

        SVProgressHUD.show(withStatus: "Fetching data, please wait!")

        let mainTabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabVC") as! MainTabViewController

        mainTabVC.selectedIndex = 2

        AppDelegate.shared.window?.rootViewController = mainTabVC

        return true
    }
    //swiftlint:enable force_cast

    func applicationDidEnterBackground(_ application: UIApplication) {

        FirebaseManager().removeAllObserver()

    }

}
