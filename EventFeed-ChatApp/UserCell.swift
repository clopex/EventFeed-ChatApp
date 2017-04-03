//
//  UserCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/2/17.
//  Copyright © 2017 MacAir. All rights reserved.
//
import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            if let toId = message?.toId {
                let ref = FIRDatabase.database().reference().child("users").child(toId)
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dict = snapshot.value as? [String: AnyObject] {
                        self.name.text = dict["name"] as? String
                        
                        if let profileImgUrl = dict["profileImageUrl"] as? String {
                            self.profileImg.loadImagesAndCache(url: profileImgUrl)
                        }
                    }
                }, withCancel: nil)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    let name: UILabel = {
        let name = UILabel()
        name.text = "Just for the testing"
        name.font = UIFont.boldSystemFont(ofSize: 14)
        name.textColor = UIColor.rgb(red: 59, green: 89, blue: 152)
        return name
    }()
    
    let profileImg: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "default_profile")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 30
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
        addSubview(profileImg)
        addSubview(name)
        
        _ = profileImg.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 10, leftConstant: 12, bottomConstant: 10, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        
        _ = name.anchor(topAnchor, left: profileImg.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

