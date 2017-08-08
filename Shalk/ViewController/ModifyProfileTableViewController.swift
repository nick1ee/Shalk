//
//  ModifyProfileTableViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/8.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ModifyProfileTableViewController: UITableViewController {
    
    enum ModifyProfileCase {
        
        case image, name, intro
        
    }
    
    var components: [ModifyProfileCase] = [ .image, .name, .intro ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return components.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

}
