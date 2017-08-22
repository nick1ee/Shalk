//
//  ChatViewController.swift
//  Shalk
//
//  Created by Nick Lee on 2017/8/5.
//  Copyright © 2017年 nicklee. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChatViewController: UIViewController {

    let imagePicker = UIImagePickerController()

    var messages: [Message] = []

    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputTextView: UITextView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var outletSend: UIButton!

    @IBOutlet weak var messageView: UIView!

    @IBOutlet weak var bottomHeight: NSLayoutConstraint!

    @IBOutlet weak var outletStartCall: UIButton!

    @IBOutlet weak var opponentName: UILabel!

    @IBAction func sendMessage(_ sender: UIButton) {

        guard let opponent = UserManager.shared.opponent else { return }

        if !inputTextView.text.isEmpty {

            FirebaseManager().checkFriendStatus(opponent.uid) { isFriend in

                if !isFriend {

                    self.messageView.isHidden = true

                    self.outletStartCall.isEnabled = false

                    let alert = UIAlertController(title: NSLocalizedString("Block_Message", comment: "") + "\(opponent.name).")

                    alert.show()

                } else {

                    FirebaseManager().sendMessage(text: self.inputTextView.text)

                    self.inputTextView.text = ""

                    self.outletSend.tintColor = UIColor.lightGray

                    self.outletSend.isEnabled = false

                }

            }

        }

    }

    @IBAction func btnBack(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func btnStartCall(_ sender: UIButton) {

        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let audioCall = UIAlertAction(title: NSLocalizedString("AudioCall", comment: ""), style: .default) { (_) in

            UserManager.shared.startAudioCall()

            self.performSegue(withIdentifier: "audioCall", sender: nil)

        }

        let videoCall = UIAlertAction(title: NSLocalizedString("VideoCall", comment: ""), style: .default) { (_) in

            self.performSegue(withIdentifier: "videoCall", sender: nil)

        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        alertSheet.addAction(audioCall)

        alertSheet.addAction(videoCall)

        alertSheet.addAction(cancel)

        self.present(alertSheet, animated: true, completion: nil)

    }

    @IBAction func btnMore(_ sender: UIButton) {

        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let block = UIAlertAction(title: NSLocalizedString("Block", comment: ""), style: .destructive) { (_) in

            let alert = UIAlertController(title: nil, message: NSLocalizedString("Block_Confirmation", comment: ""), preferredStyle: .alert)

            alert.addAction(title: NSLocalizedString("Cancel", comment: ""))

            let blockAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { (_) in

                // MARK: Block friend

                SVProgressHUD.show()

                DispatchQueue.global().async {

                    FirebaseManager().blockFriend {

                        SVProgressHUD.dismiss()

                        let alert = UIAlertController(title: nil, message: NSLocalizedString("BlockSuccessfully", comment: ""), preferredStyle: .alert)

                        alert.addAction(title: "OK", style: .default, isEnabled: true) { _ in

                            self.navigationController?.popToRootViewController(animated: true)

                        }

                        self.present(alert, animated: true, completion: nil)

                    }

                }

            })

            alert.addAction(blockAction)

            self.present(alert, animated: true, completion: nil)

        }

        let report = UIAlertAction(title: NSLocalizedString("Report", comment: ""), style: .default) { (_) in

            let alert = UIAlertController(title: NSLocalizedString("Report_Hint", comment: ""), message: nil, preferredStyle: .alert)

            alert.addTextField(configurationHandler: { (inputReason) in

                inputReason.placeholder = NSLocalizedString("Report_Reason", comment: "")

            })

            alert.addAction(title: NSLocalizedString("Cancel", comment: ""))

            let reportAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { (_) in

                if let reason = alert.textFields?[0].text {

                    if reason != "" {

                        // MARK: report friend

                        DispatchQueue.global().async {

                            FirebaseManager().reportFriend(reason) {

                                SVProgressHUD.dismiss()

                                let alert = UIAlertController(title: nil, message: NSLocalizedString("ReportSuccessfully", comment: ""), preferredStyle: .alert)

                                alert.addAction(title: "OK", style: .default, isEnabled: true) { _ in

                                    self.navigationController?.popToRootViewController(animated: true)

                                }

                                self.present(alert, animated: true, completion: nil)

                            }

                        }

                    } else {

                        // MARK: input reason could not be nil.

                        let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: ""), message: NSLocalizedString("Invalid_Reason", comment: ""), preferredStyle: .alert)

                        alert.addAction(title: "OK")

                        self.present(alert, animated: true, completion: nil)

                    }

                }

            })

            alert.addAction(reportAction)

            self.present(alert, animated: true, completion: nil)

        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        alertSheet.addAction(block)

        alertSheet.addAction(report)

        alertSheet.addAction(cancel)

        self.present(alertSheet, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.delegate = self

        prepareTableView()

        guard let opponent = UserManager.shared.opponent else { return }

        opponentName.text = opponent.name.addSpacingAndCapitalized()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        FirebaseManager().checkFriendStatus(opponent.uid) { isFriend in

            if !isFriend {

                self.messageView.isHidden = true

                self.outletStartCall.isEnabled = false

                let alert = UIAlertController(title: NSLocalizedString("Block_Message", comment: "") + "\(opponent.name).")

                alert.show()

            }

        }

        FirebaseManager().fetchChatHistory { fetchMessages in

            self.messages = fetchMessages.filter { $0.text != "" }

            self.chatTableView.reloadData({

                self.scrollToLast()

                FirebaseManager().updateChatRoom()

            })
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

        self.view.addGestureRecognizer(tap)

    }

    deinit {

        NotificationCenter.default.removeObserver(self)

    }

    func hideKeyboard() {

        self.view.endEditing(true)

    }

    func scrollToLast() {

        if self.messages.count >= 1 {

            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)

            DispatchQueue.main.async {

                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)

            }

        }

    }

    func setTapGestureRecognizer() -> UITapGestureRecognizer {

        let tapRecognizer = UITapGestureRecognizer()

        tapRecognizer.addTarget(self, action: #selector(didTapUserImage))

        return tapRecognizer

    }

    func didTapUserImage(_ gesture: UITapGestureRecognizer) {

        guard
            let opponent = UserManager.shared.opponent,
            let imageView = gesture.view as? UIImageView else { return }

        let alert = CustomAlert(title: opponent.name, intro: opponent.intro, image: imageView.image!)

        alert.show(animated: true)

    }

    func prepareTableView() {

        inputTextView.text = NSLocalizedString("InputField_Placefolder", comment: "")

        chatTableView.estimatedRowHeight = 300

        chatTableView.rowHeight = UITableViewAutomaticDimension

        outletSend.tintColor = UIColor.lightGray

        outletSend.isEnabled = false

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

        guard let myUid = UserManager.shared.currentUser?.uid else { return UITableViewCell() }

        switch messages[indexPath.row].senderId {

        case myUid:

            let cell = tableView.dequeueReusableCell(withIdentifier: "senderCell", for: indexPath) as! SenderTableViewCell

            cell.sendedMessage.text = messages[indexPath.row].text

            cell.sendedTime.text = messages[indexPath.row].time.convertDate()

            return cell

        case CallType.audio.rawValue:

            let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell

            cell.iconCallType.image = UIImage(named: "icon-audio")

            cell.callDuration.text = messages[indexPath.row].text

            cell.time.text = messages[indexPath.row].time.convertDate()

            return cell

        case CallType.video.rawValue:

            let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell

            cell.iconCallType.image = UIImage(named: "icon-camera")

            cell.callDuration.text = messages[indexPath.row].text

            cell.time.text = messages[indexPath.row].time.convertDate()

            return cell

        default:

            let friend = UserManager.shared.friends.filter { $0.uid == messages[indexPath.row].senderId }

            let cell = tableView.dequeueReusableCell(withIdentifier: "receiverCell", for: indexPath) as! ReceiverTableViewCell

            cell.receivedMessage.text = messages[indexPath.row].text

            cell.receivedTime.text = messages[indexPath.row].time.convertDate()

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

extension ChatViewController {

    func keyboardWillShow(notification: Notification) {

        let userInfo: NSDictionary = notification.userInfo! as NSDictionary

        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey)! as AnyObject).cgRectValue.size

        bottomHeight.constant = keyboardSize.height

        view.setNeedsLayout()

        self.scrollToLast()

    }

    func keyboardWillHide(notification: Notification) {

        bottomHeight.constant = 0.0

        view.setNeedsLayout()

    }

}

extension String {

    func addSpacingAndCapitalized() -> String {

        var text = ""

        for character in self.charactersArray {

            text += "\(character.uppercased) "

        }

        return text

    }

    func convertDate() -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        print(self)

        guard let date = dateFormatter.date(from: self) else { return "" }

        if Calendar.current.isDateInToday(date) {

            dateFormatter.dateFormat = "a HH:mm"

            dateFormatter.amSymbol = "AM"

            dateFormatter.pmSymbol = "PM"

            return dateFormatter.string(from: date)

        }

        if Calendar.current.isDateInYesterday(date) {

            dateFormatter.dateFormat = "HH:mm"

            return "昨天 \(dateFormatter.string(from: date))"

        } else {

            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

            return dateFormatter.string(from: date)

        }

    }

}
