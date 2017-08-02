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

    @IBOutlet weak var friendName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        friendImageView.tintColor = UIColor.init(red: 243/255, green: 174/255, blue: 47/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
