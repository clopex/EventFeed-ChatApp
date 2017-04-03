//
//  UsersViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/26/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase


class UsersViewController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUp navigation title and button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = "Users"
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        getUsersFromFireBase()
        
    }
    
    func getUsersFromFireBase() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.toId = snapshot.key
                
                //values must be the same name as on firebase aka name==name etc
                user.setValuesForKeys(dict)
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.name.text = user.name
        
        if let profileImgUrl = user.profileImageUrl {
            cell.profileImg.loadImagesAndCache(url: profileImgUrl)
        }
        
        return cell
    }
    
    var chatVC = MessagesViewController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.chatVC.showMsg(user: user)
        }
    }
    
    func logOutFromApp() {
        
        dismiss(animated: true, completion: nil)
        
//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch let logErr {
//            print(logErr)
//        }
//        
//        UserDefaults.standard.setLogdIn(value: false)
//        let loginVC = LoginViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        present(loginVC, animated: true, completion: {
//            //do something!
//        })
        
    }
 
}













