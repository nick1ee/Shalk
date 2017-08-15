//
//  CallTableViewCell.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/14.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var iconCallType: UIImageView!

    @IBOutlet weak var callDuration: UILabel!

    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
