//
//  CustomAlert.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/17.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class CustomAlert: UIView, Modal {

    var backgroundView: UIView = UIView()

    var dialogView: UIView = UIView()

    convenience init(title: String, intro: String, image: UIImage) {

        self.init(frame: UIScreen.main.bounds)

        initialize(title: title, intro: intro, image: image)

    }

    override init(frame: CGRect) {

        super.init(frame: frame)

    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")

    }

    func initialize(title: String, intro: String, image: UIImage) {

        dialogView.clipsToBounds = true

        backgroundView.frame = frame

        backgroundView.backgroundColor = UIColor.black

        backgroundView.alpha = 0.6

        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundView)))

        self.addSubview(backgroundView)

        let dialogViewWidth = frame.width - 64

        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth - 16, height: 30))

        titleLabel.text = title

        titleLabel.textAlignment = .left

        dialogView.addSubview(titleLabel)

        let introLabel = UILabel(frame: CGRect(x: 8, y: titleLabel.frame.height + 5, width: dialogViewWidth - 16, height: 60))

        introLabel.font = UIFont.systemFont(ofSize: 14)

        introLabel.textColor = UIColor.gray

        if intro != "null" {

            introLabel.text = intro

        }

        introLabel.numberOfLines = 2

        introLabel.sizeToFit()

        introLabel.textAlignment = .left

        dialogView.addSubview(introLabel)

        let separatorLineView = UIView()

        separatorLineView.frame.origin = CGPoint(x: 8, y: introLabel.frame.height + introLabel.frame.origin.y + 8)

        separatorLineView.frame.size = CGSize(width: dialogViewWidth - 16, height: 1)

        separatorLineView.backgroundColor = UIColor.groupTableViewBackground

        dialogView.addSubview(separatorLineView)

        let imageView = UIImageView()

        imageView.frame.origin = CGPoint(x: 8, y: separatorLineView.frame.height + separatorLineView.frame.origin.y + 8)

        imageView.frame.size = CGSize(width: dialogViewWidth - 16, height: dialogViewWidth - 16)

        imageView.image = image

        imageView.layer.cornerRadius = 4

        imageView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit

        imageView.tintColor = UIColor(red: 140/255, green: 35/255, blue: 154/255, alpha: 1)

        dialogView.addSubview(imageView)

        let dialogViewHeight = titleLabel.frame.height + 8 + introLabel.frame.height + 8 + separatorLineView.frame.height + 8 + imageView.frame.height + 8

        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)

        dialogView.frame.size = CGSize(width: frame.width - 64, height: dialogViewHeight)

        dialogView.backgroundColor = UIColor.white

        dialogView.layer.cornerRadius = 15

        addSubview(dialogView)

    }

    func didTapBackgroundView() {

        self.dismiss(animated: true)

    }

}
