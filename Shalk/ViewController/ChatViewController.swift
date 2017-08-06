//
//  ChatViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/5.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    var messages: [Message] = []

    let fbManager = FirebaseManager()

    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputTextView: UITextView!

    @IBAction func sendMessage(_ sender: UIButton) {

        fbManager.sendMessage(text: inputTextView.text)

        inputTextView.text = ""

        chatTableView.scrollToBottom(animated: true)

    }

    @IBAction func sendImage(_ sender: UIButton) {

    }

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnAudioCall(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "audioCall", sender: nil)

    }

    @IBAction func btnVideoCall(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "videoCall", sender: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.delegate = self

        fbManager.chatHistroyDelegate = self

        fbManager.fetchChatHistory()

        chatTableView.estimatedRowHeight = 300

        chatTableView.rowHeight = UITableViewAutomaticDimension

    }

}

//swiftlint:disable force_cast
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return  messages.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let myUid = UserManager.shared.currentUser?.uid else { return UITableViewCell() }

        switch messages[indexPath.row].senderId {

        case myUid:

            let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! SenderTableViewCell

            cell.sendedMessage.text = messages[indexPath.row].text

            cell.sendedTime.text = messages[indexPath.row].time

            return cell

        default:

            let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as! ReceiverTableViewCell

            cell.receivedMessage.text = messages[indexPath.row].text

            cell.receivedTime.text = messages[indexPath.row].time

            return cell

        }

    }

}
//swiftlint:enable force_cast

extension ChatViewController: FirebaseManagerChatHistoryDelegate {

    func manager(_ manager: FirebaseManager, didGetMessages messages: [Message]) {

        self.messages = messages

        chatTableView.reloadData()

    }

    func manager(_ manager: FirebaseManager, didGetError error: Error) {

        print(error.localizedDescription)

    }

}

extension ChatViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        if inputTextView.text == "write something.." {

            inputTextView.text = ""

        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if inputTextView.text.isEmpty {

            inputTextView.text = "write something.."

        }
    }

}
