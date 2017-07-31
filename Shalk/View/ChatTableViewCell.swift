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

    @IBOutlet weak var preferredLanguage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}