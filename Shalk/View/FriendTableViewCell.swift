//
//  FriendTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/2.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendImageView: UIImageView!

    @IBOutlet weak var friendStatus: UILabel!

    @IBOutlet weak var friendName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        friendImageView.tintColor = UIColor.init(red: 62/255, green: 48/255, blue: 76/255, alpha: 1)

        friendImageView.backgroundColor = UIColor.white

        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
