//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: Constants.cellNibName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.cellIdentifier)

        title = Constants.appName
        navigationItem.hidesBackButton = true
        
        loadMessages()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let messageBody = messageTextfield.text
        let messageSender = Auth.auth().currentUser?.email;
        
        if let messageBody = messageBody, let messageSender = messageSender {
            var ref: DocumentReference? = nil
            ref = db.collection(Constants.FStore.collectionName).addDocument(data: [
                "sender": messageSender,
                "message": messageBody,
                "timestamp": Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            
            messageTextfield.text = ""
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Signout error: \(error.localizedDescription)")
        }
    }

    func loadMessages() {
        db
            .collection(Constants.FStore.collectionName)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                if let documents = querySnapshot?.documents {
                    self.messages = []
                    for document in documents {
                        let sender = document["sender"] as? String
                        let messageBody = document["message"] as? String
                        
                        if let sender = sender, let messageBody = messageBody {
                            let message = Message(sender: sender, message: messageBody)
                            self.messages.append(message)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.scrollToLastMessage()
                        }
                    }
                }
        }
    }
    
    func scrollToLastMessage() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        
        cell.label.text = message.message
        
        if let email = Auth.auth().currentUser?.email {
            if email == message.sender {
                cell.leftImageView.isHidden = true
                cell.rightImageView.isHidden = false
                cell.messageBubble.backgroundColor = UIColor(named: "BrandPurple")
            } else {
                cell.leftImageView.isHidden = false
                cell.rightImageView.isHidden = true
                cell.messageBubble.backgroundColor = UIColor(named: "BrandBlue")
            }
        }
        return cell
    }
}

