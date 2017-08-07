//
//  AppDelegateExtensions.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

//swiftlint:disable force_cast
extension AppDelegate {

    class var shared: AppDelegate {

        return UIApplication.shared.delegate as! AppDelegate

    }
    
    func checkUserToken() -> [String: String]? {
        
        if let loadedEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let loadedPwd = UserDefaults.standard.value(forKey: "password") as? String {
            
            let userToken: [String: String] = ["email": loadedEmail, "password": loadedPwd]
            
            return userToken
            
        }else {
            
            return nil
            
        }

    }

}
//swiftlint:enable force_cast
