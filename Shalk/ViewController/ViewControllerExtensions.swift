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

}
