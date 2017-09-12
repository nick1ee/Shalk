//
//  Modal.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/17.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import Foundation

protocol Modal {

    func show(animated: Bool)

    func dismiss(animated: Bool)

    var backgroundView: UIView {get}

    var dialogView: UIView {get set}

}

extension Modal where Self: UIView {

    func show(animated: Bool) {

        self.backgroundView.alpha = 0

        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)

        if animated {

            UIView.animate(withDuration: 0.33, animations: {

                self.backgroundView.alpha = 0.66

            })

            UIView.animate(
                withDuration: 0.33,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 10.0,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: {

                self.dialogView.center  = self.center

            }, completion: { (_) in

            })

        } else {

            self.backgroundView.alpha = 0.66

            self.dialogView.center  = self.center

        }

    }

    func dismiss(animated: Bool) {

        if animated {

            UIView.animate(withDuration: 0.33, animations: {

                self.backgroundView.alpha = 0.0

            }, completion: { (_) in

            })

            UIView.animate(
                withDuration: 0.33,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 10.0,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: {

                self.dialogView.center = CGPoint(
                    x: self.center.x,
                    y: self.frame.height + self.dialogView.frame.height / 2.0
                )

            }, completion: { (_) in

                self.removeFromSuperview()

            })

        } else {

            self.removeFromSuperview()

        }

    }

}
