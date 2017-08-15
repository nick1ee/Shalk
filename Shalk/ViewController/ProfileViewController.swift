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

        self.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModifyProfile"))

    }

    @IBAction func btnLogOut(_ sender: UIBarButtonItem) {

        let alert = UIAlertController.init(title: NSLocalizedString("Logout_Title", comment: ""), message: NSLocalizedString("Logout_Message", comment: ""), preferredStyle: .alert)

        alert.addAction(title: NSLocalizedString("Cancel", comment: ""))

        alert.addAction(title: NSLocalizedString("OK", comment: ""), style: .default, isEnabled: true) { (_) in

            // MARK: User log out.

            SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Logout", comment: ""))

            UserManager.shared.logOut()

        }

        self.present(alert, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fbManager.friendDelegate = self

        prepareTableView()

        DispatchQueue.global().async {

            self.fbManager.fetchFriendList(languageType: .english)

            self.fbManager.fetchFriendList(languageType: .chinese)

            self.fbManager.fetchFriendList(languageType: .japanese)

            self.fbManager.fetchFriendList(languageType: .korean)

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SVProgressHUD.show()

        DispatchQueue.global().async {

            FirebaseManager().fetchMyProfile {

                self.tableView.reloadData()

                SVProgressHUD.dismiss()

            }

        }

    }

    func prepareTableView() {

        tableView.estimatedRowHeight = 200

        tableView.rowHeight = UITableViewAutomaticDimension

        let bgImageView = UIImageView(image: UIImage(named: "background"))

        tableView.backgroundColor = UIColor.clear

        tableView.backgroundView = bgImageView

    }

}

extension ProfileViewController: FirebaseManagerFriendDelegate {

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        SVProgressHUD.dismiss()

        // MARK: Failed to get friend info.

        UIAlertController(error: error).show()

    }

    func manager(_ manager: FirebaseManager, didGetFriend friend: User, byType: LanguageType) {

        SVProgressHUD.dismiss()

        switch byType {

        case .english:

            self.englishFriends.append(friend)

            self.tableView.reloadData()

            break

        case .chinese:

            self.chineseFriends.append(friend)

            self.tableView.reloadData()

            break

        case .japanese:

            self.japaneseFriends.append(friend)

            self.tableView.reloadData()

            break

        case .korean:

            self.koreanFriends.append(friend)

            self.tableView.reloadData()

            break

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

            cell.friendImageView.sd_setImage(with: URL(string: englishFriends[indexPath.row].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendName.text = self.englishFriends[indexPath.row].name

            cell.backgroundColor = UIColor.clear

            return cell

        case 2:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            cell.friendImageView.sd_setImage(with: URL(string: chineseFriends[indexPath.row].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendName.text = self.chineseFriends[indexPath.row].name

            cell.backgroundColor = UIColor.clear

            return cell

        case 3:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            cell.friendImageView.sd_setImage(with: URL(string: japaneseFriends[indexPath.row].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendName.text = self.japaneseFriends[indexPath.row].name

            cell.backgroundColor = UIColor.clear

            return cell

        case 4:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            cell.friendImageView.sd_setImage(with: URL(string: koreanFriends[indexPath.row].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendName.text = self.koreanFriends[indexPath.row].name

            cell.backgroundColor = UIColor.clear

            return cell

        default:

            // MARK: Display profile cell.

            guard let user = UserManager.shared.currentUser else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = user.name

            cell.userIntroduction.text = user.intro

            cell.userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.backgroundColor = UIColor.clear

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

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let dismissCell = cell as? FriendTableViewCell

        dismissCell?.friendImageView.image = nil

        dismissCell?.friendName.text = ""

    }

}
