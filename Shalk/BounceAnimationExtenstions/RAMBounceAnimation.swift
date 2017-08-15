////
////  RAMBounceAnimation.swift
////  Shalk
////
////  Created by Nick Lee on 2017/7/27.
////  Copyright © 2017年 nicklee. All rights reserved.
////
//
//import UIKit
////import RAMAnimatedTabBarController
//
//class RAMBounceAnimation: RAMItemAnimation {
//
//    let selectedColor = UIColor.init(red: 255/255, green: 189/255, blue: 0/255, alpha: 1)
//
//    override func playAnimation(_ icon: UIImageView, textLabel: UILabel) {
//
//        playBounceAnimation(icon)
//
//        icon.tintColor = selectedColor
//
//        textLabel.textColor = selectedColor
//
//    }
//
//    override func deselectAnimation(_ icon: UIImageView, textLabel: UILabel, defaultTextColor: UIColor, defaultIconColor: UIColor) {
//
//        icon.tintColor = UIColor.lightGray
//
//        textLabel.textColor = UIColor.lightGray
//
//    }
//
//    override func selectedState(_ icon: UIImageView, textLabel: UILabel) {
//
//        icon.tintColor = selectedColor
//
//        textLabel.textColor = selectedColor
//
//    }
//
//    func playBounceAnimation(_ icon: UIImageView) {
//
//        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
//
//        bounceAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
//
//        bounceAnimation.duration = TimeInterval(duration)
//
//        bounceAnimation.calculationMode = kCAAnimationCubic
//
//        icon.layer.add(bounceAnimation, forKey: "bounceAnimation")
//
//    }
//
//
//}
