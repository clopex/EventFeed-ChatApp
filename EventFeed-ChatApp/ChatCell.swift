//
//  ChatCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/5/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase

class ChatCell: UserCell {
    
    var message: Message? {
        didSet {
            setUpNameAndImage()
            
            lastMsg.text = message?.text
            if let timeFromStamp = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: timeFromStamp)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                self.time.text = timestampDate.timeAgoShow() //dateFormatter.string(from: timestampDate as Date)
            }
            
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setUpNameAndImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observe(.value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.name.text = dict["name"] as? String
                    
                    if let profileImgUrl = dict["profileImageUrl"] as? String {
                        self.profileImg.loadImagesAndCache(profileImgUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    let time: UILabel = {
        let time = UILabel()
//        time.text = "HH:MM:SS"
        time.font = UIFont.boldSystemFont(ofSize: 12)
        time.textColor = UIColor.lightGray
        time.translatesAutoresizingMaskIntoConstraints = false
        return time
    }()
    
    let lastMsg: UILabel = {
        let label = UILabel()
//        label.text = "Hello World"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.rgb(red: 59, green: 89, blue: 152)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        //layoutViews()
    }
    
    override func setupViews() {
        addSubview(seperator)
        addSubview(profileImg)
        addSubview(name)
        addSubview(time)
        addSubview(lastMsg)
        
        _ = profileImg.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 10, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        _ = name.anchor(topAnchor, left: profileImg.rightAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = time.anchor(topAnchor, left: name.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 2, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        _ = lastMsg.anchor(name.bottomAnchor, left: profileImg.rightAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = seperator.anchor(lastMsg.bottomAnchor, left: profileImg.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: -20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
