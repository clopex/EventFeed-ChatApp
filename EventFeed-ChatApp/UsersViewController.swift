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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "logout"), style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.title = "Users"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        getUsersFromFireBase()
        
    }
    
    func getUsersFromFireBase() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = User()
                
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
    
    func logOutFromApp() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logErr {
            print(logErr)
        }
        
        UserDefaults.standard.setLogdIn(value: false)
        let loginVC = LoginViewController(collectionViewLayout: UICollectionViewFlowLayout())
        present(loginVC, animated: true, completion: {
            //do something!
        })
        
    }
 
}

class UserCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}












