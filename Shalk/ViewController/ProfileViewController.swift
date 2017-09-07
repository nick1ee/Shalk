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

    var components: [ProfileCell] = [ .me, .friend ]

    @IBOutlet weak var tableView: UITableView!

    @IBAction func btnModifyProfile(_ sender: UIButton) {

        self.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModifyProfile"))

    }

    @IBAction func btnLogOut(_ sender: UIButton) {

        let alert = UIAlertController(
            title: NSLocalizedString("Logout_Title", comment: ""),
            message: NSLocalizedString("Logout_Message", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            title: NSLocalizedString("Cancel", comment: "")
        )

        alert.addAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            isEnabled: true,
            handler: { (_) in

                // MARK: User log out.

                SVProgressHUD.show(withStatus: NSLocalizedString("SVProgress_Logout", comment: ""))

                UserManager.shared.logOut()

        })

        self.present(
            alert,
            animated: true,
            completion: nil
        )

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

        DispatchQueue.global().async {

            FirebaseManager().fetchMyProfile {

                self.tableView.reloadData()

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

        tapRecognizer.addTarget(
            self,
            action: #selector(didTapUserImage)
        )

        return tapRecognizer

    }

    func didTapUserImage(_ gesture: UITapGestureRecognizer) {

        guard
            let indexNumber = gesture.view?.tag,
            let imageView = gesture.view as? UIImageView,
            let image = imageView.image
            else {

            return

        }

        let alert = CustomAlert(
            title: friends[indexNumber].name,
            intro: friends[indexNumber].intro,
            image: image
        )

        alert.show(animated: true)

    }

    func handleFriendChange() {

        self.friends = []

        self.tableView.reloadData()

    }

    deinit {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FriendChange"), object: self)

    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return components.count

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let component = components[section]

        switch component {

        case .me: return 0

        case .friend: return 30.0

        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let component = components[section]

        switch component {

        case .me: return nil

        case .friend:

            let screen = UIScreen.main.bounds

            let header = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 30))

            let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: screen.width, height: 30))

            headerLabel.font = UIFont.boldSystemFont(ofSize: 13)

            headerLabel.text = "F R I E N D S"

            headerLabel.textColor = UIColor.white

            headerLabel.layer.shadowColor = UIColor.black.cgColor

            headerLabel.layer.shadowOffset = CGSize(width: 1, height: 1)

            headerLabel.layer.shadowRadius = 10

            headerLabel.layer.opacity = 1

            header.backgroundColor = UIColor.clear

            header.addSubview(headerLabel)

            return header

        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let component = components[section]

        switch component {

        case .me:

            return 1

        case .friend:

            return friends.count

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

            if user.intro != "null" {

                cell.userIntroduction.text = user.intro

            }

            if user.imageUrl == "null" {

                let userPlaceholder = UIImage(named: "bigUser")

                cell.userImageView.image = userPlaceholder

                cell.userImageView.image = cell.userImageView.image?.withRenderingMode(.alwaysTemplate)

                cell.userImageView.tintColor = UIColor.white

                cell.userImageView.backgroundColor = UIColor.clear

            } else {

                cell.userImageView.sd_setImage(with: URL(string: user.imageUrl))

            }

            return cell

        case .friend:

            // MARK: Display cells for friends.

            let friend = friends[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            cell.friendImageView.sd_setImage(with: URL(string: friend.imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendImageView.tag = indexPath.row

            cell.friendImageView.addGestureRecognizer(setTapGestureRecognizer())

            cell.friendImageView.isUserInteractionEnabled = true

            cell.friendName.text = friend.name

            if friend.intro != "null" {

                cell.friendStatus.text = friend.intro

            }

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
