//
//  FeedsCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

//one of the option to store image to the cache, with NSCache
var cacheImagesFromUrl = NSCache<AnyObject, AnyObject>()

class FeedsCell: UICollectionViewCell {
    
    //reference to the FeedController
    var eventVC: FeedsViewController?
    
    func animate() {
        eventVC?.animateImageView(statusImageView: statusImageView)
    }
    
    var event: Event? {
        didSet {
            
            setUpProfileAndStatusImages()
            
            //Here we setup ProfileName, status text, comments, likes
            setUpViewsFromArray()
        }
    }
    
    func setUpProfileAndStatusImages() {
        
        //here we setup profile image and status image on seperate thread with NSurlsession
        
        if let statusImgUrl = event?.articleImageName {
            
            let url = URL(string: statusImgUrl)
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                }
                
                let image = UIImage(data: data!)
                
                cacheImagesFromUrl.setObject(image!, forKey: statusImgUrl as AnyObject)
                
                //Move to a background thread to do some long running work
                DispatchQueue.global(qos: .userInitiated).async {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.statusImageView.image = image
                        self.loader.stopAnimating()
                    }
                }
                
            }).resume()
          
            /*  FIRST OPTION WITH NSCAHCE!!!  */
            //here we check if image is in cache use it, otherwise go and fetch image from url
            //this is one of the option; Another option is on FeedController.swift in ViewDidLoad!
            //            if let image = cacheImagesFromUrl.object(forKey: statusImgUrl as AnyObject) as? UIImage {
            //                self.statusImageView.image = image
            //
            //            } else {
            //                let url = URL(string: statusImgUrl)
            //
            //                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            //
            //                    if error != nil {
            //                        print(error!)
            //                    }
            //
            //                    let image = UIImage(data: data!)
            //
            //                    cacheImagesFromUrl.setObject(image!, forKey: statusImgUrl as AnyObject)
            //
            //                    //Move to a background thread to do some long running work
            //                    DispatchQueue.global(qos: .userInitiated).async {
            //                        // Bounce back to the main thread to update the UI
            //                        DispatchQueue.main.async {
            //                            self.statusImageView.image = image
            //                            self.loader.stopAnimating()
            //                        }
            //                    }
            //
            //                }).resume()
            //            }
        }
        
        //here we setup profile image on seperate thread with NSurlsession
        if let profileImg = event?.profileImageName {
            let url = URL(string: profileImg)
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                }
                
                let image = UIImage(data: data!)
                
                //Move to a background thread to do some long running work
                DispatchQueue.global(qos: .userInitiated).async {
                    // Bounce back to the main thread to update the UI
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                        //self.loader.stopAnimating()
                    }
                }
                
            }).resume()
        }
    }
    
    func setUpViewsFromArray() {
        
        //we need this in order to have that text bellow main title, attrtibuteText!
        if let name = event?.name {
            
            var date = ""
            if let newDate = event?.date {
                date = newDate
            }
            
            var cityLabel = ""
            if let city = event?.location?.city {
                cityLabel = city
            }
            //Adding text to the label and one to the bottom of the label
            let attributeText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
            attributeText.append(NSMutableAttributedString(string: "\n\(date) - \(cityLabel) - ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.rgb(red: 155, green: 161, blue: 171)]))
            let paragpraphStyle = NSMutableParagraphStyle()
            paragpraphStyle.lineSpacing = 4
            
            attributeText.addAttribute(NSParagraphStyleAttributeName, value: paragpraphStyle, range: NSMakeRange(0, attributeText.string.characters.count))
            
            //adding image next to the second label, bellow main label
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "globe")
            attachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
            attributeText.append(NSAttributedString(attachment: attachment))
            
            nameLabel.attributedText = attributeText
        }
        
        if let numLike = event?.numberOfLikes {
            likeCommentLabel.text = String(describing: numLike) + " Likes"
        }
        
        if let numComm = event?.numberOfComments {
            commentLabel.text = String(describing: numComm) + " Comments"
        }
        
        if let articleText = event?.articleText {
            statusTextView.text = articleText
        }
        
        //        if let profileImageName = post?.profileImageName {
        //            profileImageView.image = UIImage(named: profileImageName)
        //        }
        //
        //        if let articleImage = post?.articleImageName {
        //            statusImageView.image = UIImage(named: articleImage)
        //        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        //for adding to the arrey we must include all of this in the didSet function, so we can access this propreties
        //        //Adding text to the label and one to the bottom of the label
        //        let attributeText = NSMutableAttributedString(string: "Author One", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
        //        attributeText.append(NSMutableAttributedString(string: "\nDecember 18.2016 - London - ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.rgb(red: 155, green: 161, blue: 171)]))
        //        let paragpraphStyle = NSMutableParagraphStyle()
        //        paragpraphStyle.lineSpacing = 4
        //
        //        attributeText.addAttribute(NSParagraphStyleAttributeName, value: paragpraphStyle, range: NSMakeRange(0, attributeText.string.characters.count))
        //
        //        //adding image next to the second label, bellow main label
        //        let attachment = NSTextAttachment()
        //        attachment.image = UIImage(named: "globe")
        //        attachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        //        attributeText.append(NSAttributedString(attachment: attachment))
        //        label.attributedText = attributeText
        
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        //imageView.image = UIImage(named: "at1")
        imageView.backgroundColor = UIColor.red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Some of the text in the text view"
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "img1")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let likeCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "400 Likes"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgb(red: 155, green: 161, blue: 171)
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "15.7K Comments"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgb(red: 155, green: 161, blue: 171)
        return label
    }()
    
    let dividerViewLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 226, green: 228, blue: 232)
        return view
    }()
    
    
    //creating one button
    //    let likeButton: UIButton = {
    //        let button = UIButton()
    //        button.setTitle("Like", for: .normal)
    //        button.setTitleColor(UIColor.rgb(red: 143, green: 150, blue: 163), for: .normal)
    //
    //        button.setImage(UIImage(named: "like"), for: .normal)
    //        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
    //        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    //        return button
    //    }()
    
    //Bottom buttons
    let likeButton = FeedsCell.bottomButtons(title: "Like", imageName: "like")
    let commentButton: UIButton = FeedsCell.bottomButtons(title: "Comment", imageName: "comment")
    let shareButton = FeedsCell.bottomButtons(title: "Share", imageName: "share")
    
    
    //function for creating more then one button
    static func bottomButtons(title: String, imageName: String) -> UIButton {
        
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.rgb(red: 143, green: 150, blue: 163), for: .normal)
        
        button.setImage(UIImage(named: imageName), for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(statusTextView)
        addSubview(statusImageView)
        addSubview(likeCommentLabel)
        addSubview(commentLabel)
        addSubview(dividerViewLine)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(shareButton)
        
        setupStatusImageViewLoader()
        
        statusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedsCell.animate as (FeedsCell) -> () -> ())))
        
        //adding constraing with extension of UIVie
        //Horizontal constraints
        addConstraintWithFormat(format: "H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        addConstraintWithFormat(format: "H:|-4-[v0]-4-|", views: statusTextView)
        addConstraintWithFormat(format: "H:|[v0]|", views: statusImageView)
        addConstraintWithFormat(format: "H:|-12-[v0]-10-[v1]|", views: likeCommentLabel, commentLabel)
        addConstraintWithFormat(format: "H:|-12-[v0]-12-|", views: dividerViewLine)
        
        //bottom buttons constraints
        addConstraintWithFormat(format: "H:|[v0(v2)][v1(v2)][v2]|", views: likeButton, commentButton, shareButton)
        
        //Vertical constraints
        addConstraintWithFormat(format: "V:|-12-[v0]", views: nameLabel)
        
        
        
        addConstraintWithFormat(format: "V:|-8-[v0(44)]-4-[v1]-4-[v2(200)]-8-[v3(24)]-8-[v4(0.4)][v5(44)]|", views: profileImageView, statusTextView, statusImageView, likeCommentLabel, dividerViewLine, likeButton)
        addConstraintWithFormat(format: "V:[v0(44)]|", views: commentButton)
        addConstraintWithFormat(format: "V:[v0(44)]|", views: shareButton)
        
        //adding top contraint for the comments label and size
        addConstraint(NSLayoutConstraint(item: commentLabel, attribute: .top, relatedBy: .equal, toItem: statusImageView, attribute: .bottom, multiplier: 1, constant: 8))
        addConstraintWithFormat(format: "V:[v0(24)]", views: commentLabel)
        
        //adding constraint passing dictionary with views
        //complex way and hard one, this one is replaced with extension and func down bellow
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0(44)]-8-[V1]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": profileImageView, "V1": nameLabel]))
        //
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        //        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0(44)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": profileImageView]))
        
        likeButton.addTarget(self, action: #selector(likePostAlert), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentPostAlert), for: .touchUpInside)
        
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        eventVC?.present(alertController, animated: true, completion: nil)
    }
    
    func likePostAlert() {
        showAlert(title: "Like!", message: "You liked the post.")
    }
    
    func commentPostAlert() {
        showAlert(title: "Comment!", message: "Thanks for leaving the comment.")
    }
    
    let loader = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func setupStatusImageViewLoader() {
        loader.hidesWhenStopped = true
        loader.startAnimating()
        loader.color = UIColor.black
        statusImageView.addSubview(loader)
        statusImageView.addConstraintWithFormat(format: "H:|[v0]|", views: loader)
        statusImageView.addConstraintWithFormat(format: "V:|[v0]|", views: loader)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
