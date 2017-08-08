//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class ProfileViewController: UIViewController {

    let fbManager = FirebaseManager()

    var englishFriends: [User] = []

    var chineseFriends: [User] = []

    var japaneseFriends: [User] = []

    var koreanFriends: [User] = []

    @IBOutlet weak var tableView: UITableView!

    @IBAction func btnModifyProfile(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "ModifyProfile", sender: nil)

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

        self.pushLogOutMessage { (_) in

            // MARK: User log out.

            SVProgressHUD.show(withStatus: "Start to log out.")

            UserManager.shared.logOut()

        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 200

        tableView.rowHeight = UITableViewAutomaticDimension

        fbManager.friendDelegate = self

        UserManager.shared.fetchChatRoomList()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fbManager.fetchFriendList()

        self.tableView.reloadData()

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.englishFriends = []

        self.chineseFriends = []

        self.japaneseFriends = []

        self.koreanFriends = []
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ModifyProfile" {

            let manageProfileVC = segue.destination as? ModifyProfileViewController

            guard let user = UserManager.shared.currentUser else { return }

            manageProfileVC?.receivedUserName = user.name

            if user.intro == "null" {

                manageProfileVC?.receivedUserIntro = ""

            } else {

                manageProfileVC?.receivedUserIntro = user.intro
            }

        }
    }

}

extension ProfileViewController: FirebaseManagerFriendDelegate {

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        // TODO: Error handling

        print(error.localizedDescription)

    }

    func manager(_ manager: FirebaseManager, didGetFriend friend: User, byLanguage: String) {

        switch byLanguage {

        case "English":

            self.englishFriends.append(friend)

            self.tableView.reloadData()

            break

        case "Chinese":

            self.chineseFriends.append(friend)

            self.tableView.reloadData()

            break

        case "Japanese":

            self.japaneseFriends.append(friend)

            self.tableView.reloadData()

            break

        case "Korean":

            self.koreanFriends.append(friend)

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

            if englishFriends.count == 0 {

                return nil

            } else {

                return "English"

            }

        case 2:

            if chineseFriends.count == 0 {

                return nil

            } else {

            return "Chinese"

            }

        case 3:

            if japaneseFriends.count == 0 {

                return nil

            } else {

            return "Japanese"

            }

        case 4:

            if koreanFriends.count == 0 {

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

            if englishFriends[indexPath.row].imageUrl != "null" {

                cell.friendImageView.sd_setImage(with: URL(string: englishFriends[indexPath.row].imageUrl))

            }

            cell.friendName.text = self.englishFriends[indexPath.row].name

            return cell

        case 2:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            if chineseFriends[indexPath.row].imageUrl != "null" {

                cell.friendImageView.sd_setImage(with: URL(string: chineseFriends[indexPath.row].imageUrl))

            }

            cell.friendName.text = self.chineseFriends[indexPath.row].name

            return cell

        case 3:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            if japaneseFriends[indexPath.row].imageUrl != "null" {

                cell.friendImageView.sd_setImage(with: URL(string: japaneseFriends[indexPath.row].imageUrl))

            }

            cell.friendName.text = self.japaneseFriends[indexPath.row].name

            return cell

        case 4:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            if koreanFriends[indexPath.row].imageUrl != "null" {

                cell.friendImageView.sd_setImage(with: URL(string: koreanFriends[indexPath.row].imageUrl))

            }

            cell.friendName.text = self.koreanFriends[indexPath.row].name

            return cell

        default:

            // MARK: Display profile cell.

            guard let user = UserManager.shared.currentUser else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = user.name

            if user.intro == "null" {

                cell.userIntroduction.text = "Add a comment to introduce yourself."

            } else {

                cell.userIntroduction.text = user.intro

            }

            if user.imageUrl != "null" {

                cell.userImageView.sd_setImage(with: URL(string: user.imageUrl))

            }

            return cell

        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {

        case 1:

            UserManager.shared.startChat(withVC: self, to: englishFriends[indexPath.row])

            break

        case 2:

            UserManager.shared.startChat(withVC: self, to: chineseFriends[indexPath.row])

            break

        case 3:

            UserManager.shared.startChat(withVC: self, to: japaneseFriends[indexPath.row])

            break

        case 4:

            UserManager.shared.startChat(withVC: self, to: koreanFriends[indexPath.row])

            break

        default: break

        }

    }

}
