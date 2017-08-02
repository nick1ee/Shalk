//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        displayUserInfo()

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

}
