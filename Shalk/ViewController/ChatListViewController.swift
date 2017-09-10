//
//  ChatListViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

// MARK: - ChatListViewController

import UIKit

class ChatListViewController: UIViewController {

    // MARK: Property

    var rooms: [ChatRoom] = []

    let fbManager = FirebaseManager()

    let btnHint: UIButton = UIButton()

    @IBOutlet weak var chatListTableView: UITableView!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fbManager.chatRoomDelegate = self

        addDiscoverButton()

        setUpBackground()

        DispatchQueue.global().async {

            self.fbManager.fetchChatRoomList()

        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRoomChange),
            name: NSNotification.Name(rawValue: "RoomChange"),
            object: nil
        )

    }

    deinit {

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "RoomChange"),
            object: self
        )

    }

    // MARK: UI Customization

    func setUpBackground() {

        let bgImageView = UIImageView(image: UIImage(named: "background"))

        chatListTableView.backgroundColor = UIColor.clear

        chatListTableView.backgroundView = bgImageView

    }

    func addDiscoverButton() {

        let screen = UIScreen.main.bounds

        btnHint.frame = CGRect(
            x: 50.0,
            y: 100.0,
            width: screen.width - 100.0,
            height: 50.0
        )

        btnHint.setTitle(
            "D I S C O V E R  !",
            for: .normal
        )

        btnHint.setTitleColor(
            UIColor.white,
            for: .normal
        )

        btnHint.backgroundColor = UIColor.clear

        btnHint.layer.borderColor = UIColor.white.cgColor

        btnHint.layer.borderWidth = 2.0

        btnHint.layer.shadowColor = UIColor.black.cgColor

        btnHint.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)

        btnHint.layer.shadowRadius = 0.5

        btnHint.layer.shadowOpacity = 1.0

        btnHint.addTarget(
            self,
            action: #selector(goDiscover),
            for: .touchDown
        )

        self.view.addSubview(btnHint)

    }

    // MARK: Selector Functions

    func handleRoomChange() {

        self.rooms = []

        self.chatListTableView.reloadData()

    }

    func goDiscover() {

        self.tabBarController?.selectedIndex = 1

    }

}

// MARK: UITableViewDelegate, UITableViewDataSource

//swiftlint:disable force_cast
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return rooms.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatRoomTableViewCell

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let myUid = UserManager.shared.currentUser?.uid else { return }

        let room = rooms[indexPath.row]

        if myUid == room.user1Id {

            UserManager.shared.chatRoomId = room.roomId

            let friend = UserManager.shared.friends.filter { $0.uid == room.user2Id }

            UserManager.shared.opponent = friend[0]

            self.performSegue(withIdentifier: "goChat", sender: nil)

        } else {

            UserManager.shared.chatRoomId = room.roomId

            let friend = UserManager.shared.friends.filter { $0.uid == room.user1Id }

            UserManager.shared.opponent = friend[0]

            self.performSegue(withIdentifier: "goChat", sender: nil)

        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let cell = cell as! ChatRoomTableViewCell

        let room = rooms[indexPath.row]

        cell.latestMessage.text = room.latestMessage

        if room.isRead == false {

            cell.newMessageBubble.isHidden = false

        } else {

            cell.newMessageBubble.isHidden = true

        }

        guard let myUid = UserManager.shared.currentUser?.uid else { return }

        if myUid == room.user1Id {

            let friend = UserManager.shared.friends.filter { $0.uid == room.user2Id }

            cell.opponentImageView.sd_setImage(with: URL(string: friend[0].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.opponentName.text = friend[0].name

        } else {

            let friend = UserManager.shared.friends.filter { $0.uid == room.user1Id }

            cell.opponentImageView.sd_setImage(with: URL(string: friend[0].imageUrl), placeholderImage: UIImage(named: "icon-user"))

            cell.opponentName.text = friend[0].name

        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let cell = cell as! ChatRoomTableViewCell

        cell.opponentImageView.image = nil

        cell.opponentName.text = nil

        cell.latestMessage.text = nil

        cell.newMessageBubble.isHidden = true

    }

}
//swiftlint:enable force_cast

// MARK: FirebaseManagerChatRoomDelegate

extension ChatListViewController: FirebaseManagerChatRoomDelegate {

    func manager(_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom]) {

        self.rooms = rooms

        btnHint.isHidden = true

        chatListTableView.reloadData()

    }

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        UIAlertController(error: error).show()

    }

}
