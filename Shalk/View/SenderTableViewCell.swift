//
//  SenderTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/6.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class SenderTableViewCell: UITableViewCell {

    @IBOutlet weak var senderImageView: UIImageView!

    @IBOutlet weak var sendedMessage: UILabel!

    @IBOutlet weak var sendedTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
