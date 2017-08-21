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

    var friends: [User] = []

    var blockedFriends: [User] = []

    var components: [FriendType] = [ .me, .friend ]

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

        prepareTableView()

        DispatchQueue.global().async {

            FirebaseManager().fetchFriendList { user in

                self.friends.append(user)

                UserManager.shared.friends.append(user)

                self.tableView.reloadData()

            }

        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleFriendChange), name: NSNotification.Name(rawValue: "FriendChange"), object: nil)

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

        tableView.estimatedRowHeight = 250

        tableView.rowHeight = UITableViewAutomaticDimension

        let bgImageView = UIImageView(image: UIImage(named: "background"))

        tableView.backgroundColor = UIColor.clear

        tableView.backgroundView = bgImageView

    }

    func setTapGestureRecognizer() -> UITapGestureRecognizer {

        let tapRecognizer = UITapGestureRecognizer()

        tapRecognizer.addTarget(self, action: #selector(didTapUserImage))

        return tapRecognizer

    }

    func didTapUserImage(_ gesture: UITapGestureRecognizer) {

        guard
            let indexNumber = gesture.view?.tag,
            let imageView = gesture.view as? UIImageView else { return }

        let alert = CustomAlert(title: friends[indexNumber].name, intro: friends[indexNumber].intro, image: imageView.image!)

        alert.show(animated: true)

    }

    func handleFriendChange() {

        self.friends = []

        self.blockedFriends = []

    }

    deinit {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FriendChange"), object: self)

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return components.count

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let component = components[section]

        switch component {

        case .me:

            return nil

        case .friend:

            return NSLocalizedString("Friend", comment: "")

        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let component = components[section]

        switch component {

        case .me:

            return 1

        case .friend:

            return self.friends.count

        }

    }

    //swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let component = components[indexPath.section]

        switch component {

        case .me:

            // MARK: Display profile cell.

            guard let user = UserManager.shared.currentUser else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            cell.userName.text = user.name

            cell.userIntroduction.text = user.intro

            cell.userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.backgroundColor = UIColor.clear

            return cell

        case .friend:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            cell.friendImageView.sd_setImage(with: URL(string: friends[indexPath.row].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendImageView.tag = indexPath.row

            cell.friendImageView.addGestureRecognizer(setTapGestureRecognizer())

            cell.friendImageView.isUserInteractionEnabled = true

            cell.friendName.text = self.friends[indexPath.row].name

            cell.friendStatus.text = self.friends[indexPath.row].intro

            return cell

        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let component = components[indexPath.section]

        switch component {

        case .me: break

        case .friend:

            UserManager.shared.startChat(withVC: self, to: friends[indexPath.row])

            break

        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let component = components[indexPath.section]

        let displayCell = cell as? FriendTableViewCell

        switch component {

        case .me: break

        case .friend:

            displayCell?.friendStatus.textColor = UIColor.lightGray

        }

    }
}
