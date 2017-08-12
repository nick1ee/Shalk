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

}
//swiftlint:enable force_cast
