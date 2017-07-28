//
//  MainTabBarController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class MainTabBarController: RAMAnimatedTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = .default

        let ramTBC = AppDelegate.shared.window?.rootViewController as? MainTabBarController

        ramTBC?.selectedIndex = 1

        ramTBC?.setSelectIndex(from: 0, to: 1)

        ramTBC?.tabBar.barTintColor = UIColor.white

    }

}
