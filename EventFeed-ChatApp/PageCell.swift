//
//  LoginCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        
        didSet {
            guard let page = page else {
                return
            }
            
            var imageName = page.imageName
            if UIDevice.current.orientation.isLandscape {
                imageName += "_land"
            }
            
            mainImageView.image = UIImage(named: imageName)
            let color = UIColor(white: 0.2, alpha: 1)
            let attributeText = NSMutableAttributedString(string: page.title, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium), NSForegroundColorAttributeName: color])
            attributeText.append(NSAttributedString(string: "\n\n\(page.message)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: color]))
            
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let length = attributeText.string.characters.count
            attributeText.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: length))
            
            //textView.text = page.title + "\n\n" + page.message
            textView.attributedText = attributeText
        }
    }
    
    let mainImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.image = UIImage(named: "intro1")
        return image
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        textView.isEditable = false
        return textView
    }()
    
    func setupViews() {
        addSubview(mainImageView)
        addSubview(textView)
        
        addConstraintWithFormat(format: "H:|[v0]|", views: mainImageView)
        addConstraintWithFormat(format: "H:|-16-[v0]-16-|", views: textView)
        addConstraintWithFormat(format: "V:|[v0][v1(180)]|", views: mainImageView, textView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
