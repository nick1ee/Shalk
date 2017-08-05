//
//  ChatListViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/7/27.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {

    let fbManager = FirebaseManager()

    var rooms: [ChatRoom] = []

    @IBOutlet weak var chatListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        fbManager.delegate = self

        fbManager.fetchChatRoomList()

    }

}

//swiftlint:disable force_cast
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return rooms.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell

        guard let myUid = UserManager.shared.currentUser?.uid else { return UITableViewCell() }

        let room = rooms[indexPath.row]

        if myUid == room.user1Id {

            cell.opponentName.text = room.user2Name

            return cell

        } else {

            cell.opponentName.text = room.user1Name

            return cell

        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("push~~~~~~~~")

        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC")

        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        chatVC.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(chatVC, animated: true)

    }

}
//swiftlint:enable force_cast

extension ChatListViewController: FirebaseManagerDelegate {

    func manager(_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom]) {

        self.rooms = rooms

        chatListTableView.reloadData()

    }

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        print(error.localizedDescription)

    }

    func manager(_ manager: FirebaseManager, didGetFriend friend: User, byLanguage: String) {

    }

}
