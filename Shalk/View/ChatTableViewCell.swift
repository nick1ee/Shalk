//
//  ChatRoomTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/29.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var opponentImageView: UIImageView!

    @IBOutlet weak var opponentName: UILabel!

    @IBOutlet weak var latestMessage: UILabel!

    @IBOutlet weak var newMessageBubble: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        opponentImageView.tintColor = UIColor.white

        opponentImageView.backgroundColor = UIColor.clear

        self.backgroundColor = UIColor.clear

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
