//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    let fbManager = FirebaseManager()

    var isExistedEnglishFriends: Bool = false

    var isExistedChineseFriends: Bool = false

    var isExistedJapaneseFriends: Bool = false

    var isExistedKoreanFriends: Bool = false

    var englishFriends: [Friend] = []

    var chineseFriends: [Friend] = []

    var japaneseFriends: [Friend] = []

    var koreanFriends: [Friend] = []

    var englishFriendUIDs: [String] = [] {

        didSet {

            if englishFriendUIDs.count != 0 {

                isExistedEnglishFriends = true

                fbManager.fetchFriendsInfo(withUsers: englishFriendUIDs, withLang: "English")

            }

        }

    }

    var chineseFriendUIDs: [String] = [] {

        didSet {

            if chineseFriendUIDs.count != 0 {

                isExistedChineseFriends = true

                fbManager.fetchFriendsInfo(withUsers: chineseFriendUIDs, withLang: "Chinese")

            }

        }

    }

    var japaneseFriendUIDs: [String] = [] {

        didSet {

            if japaneseFriendUIDs.count != 0 {

                isExistedJapaneseFriends = true

                fbManager.fetchFriendsInfo(withUsers: japaneseFriendUIDs, withLang: "Japanese")

            }

        }

    }

    var koreanFriendUIDs: [String] = [] {

        didSet {

            if koreanFriendUIDs.count != 0 {

                isExistedKoreanFriends = true

                fbManager.fetchFriendsInfo(withUsers: koreanFriendUIDs, withLang: "Korean")

            }

        }

    }

    @IBOutlet weak var tableView: UITableView!

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 200

        tableView.rowHeight = UITableViewAutomaticDimension

        fbManager.delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.global().async {

            self.englishFriendUIDs = self.separateFriends(withLanguage: "English")

            self.chineseFriendUIDs = self.separateFriends(withLanguage: "Chinese")

            self.japaneseFriendUIDs = self.separateFriends(withLanguage: "Japanese")

            self.koreanFriendUIDs = self.separateFriends(withLanguage: "Korean")

        }

    }

    func separateFriends(withLanguage language: String) -> [String] {

        guard let friends = UserManager.shared.currentUser?.friends.filter({ $0.value == language }).map({ $0.key }) else {

            return []

        }

        return friends

    }

}

extension ProfileViewController: FirebaseManagerDelegate {

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        // TODO: Error handling

        print(error.localizedDescription)

    }

    func manager(_ manager: FirebaseManager, didGetList friends: [Friend], byLanguage: String) {

        switch byLanguage {

        case "English":

            self.englishFriends = friends

            self.tableView.reloadData()

            break

        case "Chinese":

            self.chineseFriends = friends

            self.tableView.reloadData()

            break

        case "Japanese":

            self.japaneseFriends = friends

            self.tableView.reloadData()

            break

        case "Korean":

            self.koreanFriends = friends

            self.tableView.reloadData()

            break

        default: break

        }

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 5

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch section {

        case 1:

            if isExistedEnglishFriends == false {

                return nil

            } else {

                return "English"

            }

        case 2:

            if isExistedChineseFriends == false {

                return nil

            } else {

            return "Chinese"

            }

        case 3:

            if isExistedJapaneseFriends == false {

                return nil

            } else {

            return "Japanese"

            }

        case 4:

            if isExistedKoreanFriends == false {

                return nil

            } else {

                return "Korean"

            }

        default:

            return nil
        }

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

        switch indexPath.section {

        case 1:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

//            cell.friendImageView.image =

            cell.friendName.text = self.englishFriends[indexPath.row].name

            return cell

        case 2:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

//            cell.friendImageView.image =

            cell.friendName.text = self.chineseFriends[indexPath.row].name

            return cell

        case 3:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

//            cell.friendImageView.image =

            cell.friendName.text = self.japaneseFriends[indexPath.row].name

            return cell

        case 4:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

//            cell.friendImageView.image =

            cell.friendName.text = self.koreanFriends[indexPath.row].name

            return cell

        default:

            // MARK: Display profile cell.

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = UserManager.shared.currentUser?.name

            if UserManager.shared.currentUser?.intro == "null" {

                cell.userIntroduction.text = "Add a comment to introduct yourself."

            } else {

                cell.userIntroduction.text = UserManager.shared.currentUser?.intro

            }

            return cell

        }

    }

}
