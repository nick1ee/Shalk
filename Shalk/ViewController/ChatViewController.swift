//
//  ChatViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/5.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    let imagePicker = UIImagePickerController()

    var messages: [Message] = []

    let fbManager = FirebaseManager()

    var opponent: User!

    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputTextView: UITextView!

    @IBOutlet weak var outletSend: UIButton!

    @IBAction func sendMessage(_ sender: UIButton) {

        if !inputTextView.text.isEmpty {

            fbManager.sendMessage(text: inputTextView.text)

            inputTextView.text = ""

            outletSend.tintColor = UIColor.lightGray

            outletSend.isEnabled = false

        }

    }

    @IBAction func btnBack(_ sender: UIBarButtonItem) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnAudioCall(_ sender: UIBarButtonItem) {

        let alert = UIAlertController.init(title: NSLocalizedString("AudioCall", comment: ""), message: NSLocalizedString("AudioCall_Message", comment: "") + "\(opponent.name)?", preferredStyle: .alert)

        alert.addAction(title: NSLocalizedString("Cancel", comment: ""))

        alert.addAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, isEnabled: true) { (_) in

            UserManager.shared.startAudioCall()

            self.performSegue(withIdentifier: "audioCall", sender: nil)
        }

        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func btnVideoCall(_ sender: UIBarButtonItem) {

        let alert = UIAlertController.init(title: NSLocalizedString("VideoCall", comment: ""), message: NSLocalizedString("VideoCall_Message", comment: "") + "\(opponent.name)?", preferredStyle: .alert)

        alert.addAction(title: NSLocalizedString("Cancel", comment: ""))

        alert.addAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, isEnabled: true) { (_) in

            self.performSegue(withIdentifier: "videoCall", sender: nil)

        }

        self.present(alert, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.text = NSLocalizedString("InputField_Placefolder", comment: "")

        inputTextView.delegate = self

        chatTableView.estimatedRowHeight = 300

        chatTableView.rowHeight = UITableViewAutomaticDimension

        outletSend.tintColor = UIColor.lightGray

        outletSend.isEnabled = false

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        opponent = UserManager.shared.opponent

        self.navigationItem.title = opponent.name

        fbManager.fetchChatHistory { fetchMessages in

            self.messages = fetchMessages.filter { $0.text != "" }

            self.chatTableView.reloadData({

                self.scrollToLast()

            })
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        FirebaseManager().updateChatRoom()

    }

    func scrollToLast() {

        if self.messages.count >= 1 {

            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)

            DispatchQueue.main.async {

                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

            }

        }

    }

    func setTapGestureRecognizer() -> UITapGestureRecognizer {

        let tapRecognizer = UITapGestureRecognizer()

        tapRecognizer.addTarget(self, action: #selector(didTapUserImage))

        return tapRecognizer

    }

    func didTapUserImage(_ gesture: UITapGestureRecognizer) {

        guard let imageView = gesture.view as? UIImageView else { return }

        let alert = CustomAlert(title: opponent.name, intro: opponent.intro, image: imageView.image!)

        alert.show(animated: true)

    }

}

//swiftlint:disable force_cast
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return messages.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let gradientLayer = CAGradientLayer()

        guard let myUid = UserManager.shared.currentUser?.uid else { return UITableViewCell() }

        switch messages[indexPath.row].senderId {

        case myUid:

            let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! SenderTableViewCell

            cell.sendedMessage.text = messages[indexPath.row].text

            cell.sendedTime.text = messages[indexPath.row].time

            gradientLayer.frame = cell.bounds

            let color1 = UIColor.init(red: 44/255, green: 33/255, blue: 76/255, alpha: 1).cgColor

            let color2 = UIColor.init(red: 62/255, green: 47/255, blue: 75/255, alpha: 1).cgColor

            gradientLayer.colors = [color1, color2]

            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)

            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

            cell.layer.insertSublayer(gradientLayer, at: 0)

            return cell

        case "Audio Call":

            let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell

            cell.iconCallType.image = UIImage(named: "icon-audio")

            cell.callDuration.text = messages[indexPath.row].text

            cell.time.text = messages[indexPath.row].time

            return cell

        case "Video Call":

            let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell

            cell.iconCallType.image = UIImage(named: "icon-camera")

            cell.callDuration.text = messages[indexPath.row].text

            cell.time.text = messages[indexPath.row].time

            return cell

        default:

            let friend = UserManager.shared.friends.filter { $0.uid == messages[indexPath.row].senderId }

            let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as! ReceiverTableViewCell

            cell.receivedMessage.text = messages[indexPath.row].text

            cell.receivedTime.text = messages[indexPath.row].time

            cell.receiverImageView.sd_setImage(with: URL(string: friend[0].imageUrl))

            cell.receiverImageView.addGestureRecognizer(setTapGestureRecognizer())

            cell.receiverImageView.isUserInteractionEnabled = true

            return cell

        }

    }

}

extension ChatViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {

        if !inputTextView.text.isEmpty {

            outletSend.tintColor = UIColor.white

            outletSend.isEnabled = true

        } else {

            outletSend.tintColor = UIColor.lightGray

            outletSend.isEnabled = false

        }

    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        if inputTextView.text == NSLocalizedString("InputField_Placefolder", comment: "") {

            inputTextView.text = ""

        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if inputTextView.text.isEmpty {

            inputTextView.text = NSLocalizedString("InputField_Placefolder", comment: "")

            outletSend.tintColor = UIColor.lightGray

            outletSend.isEnabled = false

        }
    }

}
