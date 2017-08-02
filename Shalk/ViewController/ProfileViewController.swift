//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 200

        tableView.rowHeight = UITableViewAutomaticDimension

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 2

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 0:

            return 1

        default:

            return 10

        }

    }

    //swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath {

        case [0, 0]:

            // MARK: Display profile cell.

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = UserManager.shared.currentUser?.name

            return cell

        default:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

//            cell.friendImageView.image = 

            cell.friendName.text = "friend"

            return cell

        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch  section {

        case 0:

            return 0

        default:

            return 30

        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let screenSize = UIScreen.main.bounds

        if section == 1 {

            let header = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 30))

            header.backgroundColor = UIColor.init(red: 243/255, green: 174/255, blue: 47/255, alpha: 1)

            let iconFriend = UIImageView.init(image: UIImage(named: "icon-friend.png"))

            iconFriend.tintColor = UIColor.white

            iconFriend.frame = CGRect(x: screenSize.width / 2 - 15, y: 2, width: 25, height: 25)

            let friendAmountLabel = UILabel(frame: CGRect(x: screenSize.width / 2 + 10, y: 2, width: 25, height: 25))

            friendAmountLabel.text = "10"

            friendAmountLabel.textColor = UIColor.white

            header.addSubview(iconFriend)

            header.addSubview(friendAmountLabel)

            return header

        }

        return nil
    }

}
