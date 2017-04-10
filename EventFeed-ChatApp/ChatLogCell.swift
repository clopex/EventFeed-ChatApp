//
//  ChatLogCell.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/7/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import AVFoundation

class ChatLogCell: UICollectionViewCell {
    
    var chatLogController: ChatViewController?
    var message: Message?
    
    let indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        return button
    }()
    
    let textLabel: UITextView = {
        let text = UITextView()
        text.text = "Sample"
        //text.textColor = .red
        text.isEditable = false
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 16)
        text.backgroundColor = UIColor.clear
        text.textColor = .white
        return text
    }()
    
    static let blueColor = UIColor.rgb(red: 0, green: 137, blue: 249)
    
    let sendView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = blueColor
        return view
    }()
    
    lazy var messageImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomImage)))
        return image
    }()
    
    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "default_profile")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 20
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func playVideo() {
        if let videoUrlString = message?.videoUrl, let url = NSURL(string: videoUrlString) {
            player = AVPlayer(url: url as URL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = sendView.bounds
            sendView.layer.addSublayer(playerLayer!)
            player?.play()
            indicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        indicatorView.stopAnimating()
    }
    
    func handleZoomImage(tapGesture: UITapGestureRecognizer) {
        
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.startZoomImageView(startImageView: imageView)
        }
        
    }
    
    var sendViewWidthAnchor: NSLayoutConstraint?
    var sendViewRightAnchor: NSLayoutConstraint?
    var sendViewLeftAnchor: NSLayoutConstraint?
    
    func setupViews() {
        addSubview(sendView)
        addSubview(textLabel)
        addSubview(profileImageView)
        
        sendView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: sendView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: sendView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: sendView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: sendView.heightAnchor).isActive = true
        
        sendView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: sendView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: sendView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        sendView.addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: sendView.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: sendView.centerYAnchor).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        sendViewRightAnchor = sendView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        sendViewRightAnchor?.isActive = true
        
        sendViewLeftAnchor = sendView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)

        sendView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sendViewWidthAnchor = sendView.widthAnchor.constraint(equalToConstant: 150)
        sendViewWidthAnchor?.isActive = true
        sendView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //textLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textLabel.leftAnchor.constraint(equalTo: sendView.leftAnchor, constant: 8).isActive = true
        textLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textLabel.rightAnchor.constraint(equalTo: sendView.rightAnchor).isActive = true
//        textLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        textLabel.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
















