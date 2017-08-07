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

    var opponentUid = ""

    var opponentName = ""

    @IBOutlet weak var chatListTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        fbManager.chatRoomDelegate = self

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

        guard let myUid = UserManager.shared.currentUser?.uid else { return }

        let room = rooms[indexPath.row]

        if myUid == room.user1Id {

            UserManager.shared.chatRoomId = room.roomId

            opponentName = room.user2Name

            opponentUid = room.user2Id

            self.performSegue(withIdentifier: "goChat", sender: nil)

        } else {

            UserManager.shared.chatRoomId = room.roomId

            opponentName = room.user1Name

            opponentUid = room.user1Id

            self.performSegue(withIdentifier: "goChat", sender: nil)

        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "goChat" {

            let chatVC = segue.destination as? ChatViewController

            chatVC?.opponentName = self.opponentName

            chatVC?.opponentUid = self.opponentUid

        }
    }

}
//swiftlint:enable force_cast

extension ChatListViewController: FirebaseManagerChatRoomDelegate {

    func manager(_ manager: FirebaseManager, didGetChatRooms rooms: [ChatRoom]) {

        self.rooms = rooms

        chatListTableView.reloadData()

    }

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        print(error.localizedDescription)

    }

}
