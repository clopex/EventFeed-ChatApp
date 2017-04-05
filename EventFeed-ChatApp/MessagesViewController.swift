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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "logout"), style: .plain, target: self, action: #selector(logOutFromApp)) //UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "newmessage"), style: .plain, target: self, action: #selector(createNewMessage)) //UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        observerMessages()
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellId)
    }
    
    var messages = [Message]()
    var messagesDict = [String: Message]()
    
    func observerMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dict)
                //self.messages.append(message)
                
                if let toId = message.toId {
                    self.messagesDict[toId] = message
                    self.messages = Array(self.messagesDict.values)
                    self.messages.sort(by: { (msg1, msg2) -> Bool in
                        return (msg1.timestamp?.intValue)! > (msg2.timestamp?.intValue)!
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
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
