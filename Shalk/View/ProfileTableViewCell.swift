//
//  ProfileTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/2.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var userIntroduction: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.tintColor = UIColor.init(red: 62/255, green: 48/255, blue: 76/255, alpha: 1)

        userImageView.backgroundColor = UIColor.white

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
