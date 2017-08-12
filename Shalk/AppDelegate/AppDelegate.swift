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
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        do {

            try UserManager.shared.restore(from: .appToken)

        } catch {

        }

//        guard
//            let userToken = UserManager.shared.fetchToken(),
//            let email = userToken["email"],
//            let password = userToken["password"] else { return true }

//        UserManager.shared.logIn(withEmail: email, withPassword: password)

        SVProgressHUD.show(withStatus: "Token loaded, continute to log in.")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
