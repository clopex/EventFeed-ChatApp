//
//  ChatViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/1/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UICollectionViewController, UITextFieldDelegate {
    
    var user: User?{
        didSet {
            navigationItem.title = user?.name
        }
    }

    
    lazy var enterMessageField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Your Message..."
        field.font = UIFont.systemFont(ofSize: 13)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        return field
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SEND", for: .normal)
        button.tintColor = UIColor.rgb(red: 40, green: 83, blue: 136)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        collectionView?.backgroundColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        
        setupBottomContainer()
    }
    
    func setupBottomContainer() {
        
        let containerView = UIView()
        //containerView.backgroundColor = .red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        _ = containerView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.rgb(red: 107, green: 144, blue: 239)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorView)
        
        _ = seperatorView.anchor(nil, left: view.leftAnchor, bottom: containerView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
  
        containerView.addSubview(sendButton)
        _ = sendButton.anchor(containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: containerView.frame.height)

        containerView.addSubview(enterMessageField)
        _ = enterMessageField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    func sendMessage() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.toId!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        let values: [String: AnyObject] = ["text": enterMessageField.text! as AnyObject, "toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timeStamp]
        //let values = ["text": enterMessageField.text!, "toId": id, "fromId": fromId, "timesStamp": timeStamp] as [String : Any]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}


























