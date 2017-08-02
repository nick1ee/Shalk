//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var englishFriends: [String] = []

    var chineseFriends: [String] = []

    var japaneseFriends: [String] = []

    var koreanFriends: [String] = []

    @IBOutlet weak var tableView: UITableView!

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        englishFriends = self.separateFriends(withLanguage: "English")

        chineseFriends = self.separateFriends(withLanguage: "Chinese")

        japaneseFriends = self.separateFriends(withLanguage: "Japanese")

        koreanFriends = self.separateFriends(withLanguage: "Korean")

        tableView.estimatedRowHeight = 200

        tableView.rowHeight = UITableViewAutomaticDimension

    }

    func separateFriends(withLanguage language: String) -> [String] {

        guard let friends = UserManager.shared.currentUser?.friends.filter({ $0.value == language }).map({ $0.key }) else {

            return []

        }

        return friends

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        var count = 1

        if englishFriends.count != 0 {

            count += 1

        }

        if chineseFriends.count != 0 {

            count += 1

        }

        if japaneseFriends.count != 0 {

            count += 1

        }

        if koreanFriends.count != 0 {

            count += 1

        }

        return count

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {

        case 1:

            return englishFriends.count

        case 2:

            return chineseFriends.count

        case 3:

            return japaneseFriends.count

        case 4:

            return koreanFriends.count

        default:

            return 1
        }

    }

    //swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath {

        case [0, 0]:

            // MARK: Display profile cell.

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = UserManager.shared.currentUser?.name

            if UserManager.shared.currentUser?.intro == "null" {

                cell.userIntroduction.text = "Add a comment to introduct yourself."

            } else {

                cell.userIntroduction.text = UserManager.shared.currentUser?.intro

            }

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

            header.backgroundColor = UIColor.white

            let friendAmountLabel = UILabel(frame: CGRect(x: screenSize.width / 2 - 30, y: 2, width: 80, height: 25))

            friendAmountLabel.text = "English"

            friendAmountLabel.textColor = UIColor.init(red: 243/255, green: 174/255, blue: 47/255, alpha: 1)

            header.addSubview(friendAmountLabel)

            return header

        }

        return nil
    }

}
