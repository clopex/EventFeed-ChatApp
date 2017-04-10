//
//  MessagesViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/31/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    var messagesDict = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "logout"), style: .plain, target: self, action: #selector(logOutFromApp)) //UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = "Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "newmessage"), style: .plain, target: self, action: #selector(createNewMessage)) //UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        messages.removeAll()
        messagesDict.removeAll()
        tableView.reloadData()
        
//        observerMessages()
        observerUserMessages()
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsSelectionDuringEditing = true
    }
    
    func observerUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageId(messageId: messageId)

            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDict.removeValue(forKey: snapshot.key)
            self.reloadTableView()
        }, withCancel: nil)
    }
    
    private func fetchMessageId(messageId: String) {
        let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message(dict: dict)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDict[chatPartnerId] = message
                }
                
                self.reloadTableView()
            }
            
        }, withCancel: nil)
    }
    
    private func reloadTableView() {
        self.messages = Array(self.messagesDict.values)
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return (msg1.timestamp?.intValue)! > (msg2.timestamp?.intValue)!
        })
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
//    func observerMessages() {
//        let ref = FIRDatabase.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//            if let dict = snapshot.value as? [String: AnyObject] {
//                let message = Message()
//                message.setValuesForKeys(dict)
//                //self.messages.append(message)
//                
//                if let toId = message.toId {
//                    self.messagesDict[toId] = message
//                    self.messages = Array(self.messagesDict.values)
//                    self.messages.sort(by: { (msg1, msg2) -> Bool in
//                        return (msg1.timestamp?.intValue)! > (msg2.timestamp?.intValue)!
//                    })
//                }
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//            
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "celld")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        //cell.textLabel?.text = message.text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        
        ref.observe(.value, with: { (snapshot) in
            
            guard let dict = snapshot.value as? [String: AnyObject] else {return}
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dict)
            self.showMsg(user: user)
        }, withCancel: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Faild, ", error!)
                }
                
                self.messagesDict.removeValue(forKey: chatPartnerId)
                self.reloadTableView()
                
            })
        }
    }
    
    func showMsg(user: User) {
        let chatVC = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.user = user
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func createNewMessage() {
        let usersVC = UsersViewController()
        usersVC.chatVC = self
        let navController = UINavigationController(rootViewController: usersVC)
        present(navController, animated: true, completion: nil)
    }
    
    func logOutFromApp() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logErr {
            print(logErr)
        }
        
        UserDefaults.standard.setLogdIn(value: false)
        let loginVC = LoginViewController()
        present(loginVC, animated: true, completion: {
            //do something!
        })
        
    }

}
