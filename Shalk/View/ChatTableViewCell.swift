//
//  ChatTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/29.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentName: UILabel!

    @IBOutlet weak var latestMessage: UILabel!

    @IBOutlet weak var newMessageBubble: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        newMessageBubble.tintColor = UIColor.init(red: 243/255, green: 174/255, blue: 47/255, alpha: 1)

        opponentImageView.tintColor = UIColor.white

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
