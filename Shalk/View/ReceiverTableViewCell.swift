//
//  ReceiverTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ReceiverTableViewCell: UITableViewCell {

    @IBOutlet weak var receiverImageView: UIImageView!

    @IBOutlet weak var receivedMessage: UILabel!

    @IBOutlet weak var receivedTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.clear

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
