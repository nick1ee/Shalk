//
//  ProfileViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - ProfileViewController

import UIKit
import SDWebImage
import SVProgressHUD

class ProfileViewController: UIViewController {

    // MARK: Property

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

    // MARK: Life Cycle

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

    deinit {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FriendChange"), object: self)

    }

    // MARK: UI Customization

    func prepareTableView() {

        tableView.estimatedRowHeight = 250.0

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

    // MARK: Selector Functions

    func didTapUserImage(_ gesture: UITapGestureRecognizer) {

        guard
            let indexNumber = gesture.view?.tag,
            let imageView = gesture.view as? UIImageView,
            let image = imageView.image
            else {

            return

        }

        let friend = friends[indexNumber]

        let alert = CustomAlert(
            title: friend.name,
            intro: friend.intro,
            image: image
        )

        alert.show(animated: true)

    }

    func handleFriendChange() {

        self.friends = []

        self.tableView.reloadData()

    }

}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return components.count

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        let component = components[section]

        switch component {

        case .me: return 0.0

        case .friend: return 30.0

        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let component = components[section]

        switch component {

        case .me: return nil

        case .friend:

            let screen = UIScreen.main.bounds

            let header = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screen.width, height: 30.0))

            let headerLabel = UILabel(frame: CGRect(x: 20.0, y: 0.0, width: screen.width, height: 30.0))

            headerLabel.font = UIFont.boldSystemFont(ofSize: 13)

            headerLabel.text = "F R I E N D S"

            headerLabel.textColor = UIColor.white

            headerLabel.layer.shadowColor = UIColor.black.cgColor

            headerLabel.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)

            headerLabel.layer.shadowRadius = 10.0

            headerLabel.layer.opacity = 1.0

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

            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell

            return cell

        case .friend:

            // MARK: Display cells for friends.

            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell

            return cell

        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let component = components[indexPath.section]

        switch component {

        case .me: break

        case .friend:

            UserManager.shared.startChat(withVC: self, to: friends[indexPath.row])

        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let component = components[indexPath.section]

        switch component {

        case .me:

            let cell = cell as! ProfileTableViewCell

            if let user = UserManager.shared.currentUser {

                cell.userName.text = user.name

                if user.intro != "null" {

                    cell.userIntroduction.text = user.intro

                }

                if user.imageUrl != "null" {

                    cell.userImageView.sd_setImage(with: URL(string: user.imageUrl))

                }

            }

        case .friend:

            let cell = cell as! FriendTableViewCell

            let friend = friends[indexPath.row]

            cell.friendImageView.sd_setImage(with: URL(string: friend.imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.friendImageView.tag = indexPath.row

            cell.friendImageView.addGestureRecognizer(setTapGestureRecognizer())

            cell.friendImageView.isUserInteractionEnabled = true

            cell.friendName.text = friend.name

            if friend.intro != "null" {

                cell.friendStatus.text = friend.intro

            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let component = components[indexPath.section]

        switch component {

        case .me:

            break

        case .friend:

            let cell = cell as! FriendTableViewCell

            cell.friendName.text = nil

            cell.friendStatus.text = nil

            cell.friendImageView.image = nil

            cell.friendImageView.isUserInteractionEnabled = false

        }
    }
    
    //swiftlint:enable force_cast
}
