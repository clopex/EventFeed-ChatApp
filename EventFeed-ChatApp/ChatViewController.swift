//
//  ChatViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/1/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatViewController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var bottomConstraint: NSLayoutConstraint?
    let cellId = "cellid"
    
    var user: User?{
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        ref.observe(.childAdded, with: { (snapshot) in
            let msgId = snapshot.key
            let msgRef = FIRDatabase.database().reference().child("messages").child(msgId)
            
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String: AnyObject] else {return}
                
                
                self.messages.append(Message(dict: dict))
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
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
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let seperatortView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 107, green: 144, blue: 239)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "photo")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadImage)))
        image.isUserInteractionEnabled = true
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = true
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        navigationItem.leftBarButtonItem?.tintColor = .white
        collectionView?.keyboardDismissMode = .interactive
        self.navigationController?.navigationBar.tintColor = .white
        
        collectionView?.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        
        setupBottomContainer()
        observeKeyboard()
    }
    
    func uploadImage() {
        callAlertViewForImage()
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //here we select video for upload to messanger
        if let videoUrl = info[UIImagePickerControllerMediaURL] {
            uploadVideoToFirebase(url: videoUrl as! NSURL)
        } else {
            //here we selected image for upload to messanger
            handleImageUpload(info: info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadVideoToFirebase(url: NSURL) {
        
        let videoName = NSUUID().uuidString + ".mov"
        let ref = FIRStorage.storage().reference().child("message_movies").child(videoName).putFile(url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print(error!)
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumnbnailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadImageToFirebase(image: thumbnailImage, completion: { (imageUrl) in
                        let propreties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(propeties: propreties)
                    })
                    
                    
                }
            }
        })
        
        ref.observe(.progress) { (snapshot) in
            if let completeUploadUnit = snapshot.progress?.completedUnitCount {
                //some indicator for uploading image here
            }
        }
        
        ref.observe(.success) { (snapshot) in
            //some indicatior when upload is finished
        }
    }
    
    private func thumnbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl as URL)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try assetGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    func handleImageUpload(info: [String: AnyObject]) {
        
        var selectImg: UIImage?
        
        if let editImg = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImg = editImg
        } else if let orginalImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectImg = orginalImg
        }
        
        if let image = selectImg {
            uploadImageToFirebase(image: image, completion: { (imageUrl) in
                 self.sendMessageWithImage(imageUrl: imageUrl, image: image)
            })
        }

    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Faild to upload Image", error!)
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
        
    }
    
    func callAlertViewForImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        picker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source for your photo", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                print("No camera")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupBottomContainer() {
        
        view.addSubview(containerView)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: containerView)
        view.addConstraintWithFormat(format: "V:[v0(50)]", views: containerView)
        
        bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        containerView.addSubview(imageView)
        containerView.addSubview(enterMessageField)
        containerView.addSubview(sendButton)
        containerView.addSubview(seperatortView)
        
        containerView.addConstraintWithFormat(format: "H:|-5-[v0(25)]-10-[v1][v2(60)]|", views: imageView, enterMessageField, sendButton)
        //imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.addConstraintWithFormat(format: "V:|-12-[v0(26)]-12-|", views: imageView)
        containerView.addConstraintWithFormat(format: "V:|[v0]|", views: enterMessageField)
        containerView.addConstraintWithFormat(format: "V:|[v0]|", views: sendButton)
        containerView.addConstraintWithFormat(format: "H:|[v0]|", views: seperatortView)
        containerView.addConstraintWithFormat(format: "V:|[v0(0.5)]", views: seperatortView)
        
    }
    
    func sendMessage() {
        
        let propreties: [String: AnyObject] = ["text": enterMessageField.text! as AnyObject]
        sendMessageWithProperties(propeties: propreties)
    }
    
    private func sendMessageWithImage(imageUrl: String, image: UIImage) {
        
        let propeties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessageWithProperties(propeties: propeties)
    }
    
    private func sendMessageWithProperties(propeties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timeStamp]
        
        propeties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipUserMsg = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipUserMsg.updateChildValues([messageId: 1])
            self.enterMessageField.text = nil
        }
    }
    
    fileprivate func observeKeyboard() {
        //NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboard(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboard = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let isKeyboardShow = notification.name == .UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShow ? -keyboard.height : 0
            print(keyboard.height)
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: { 
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                if isKeyboardShow {
                    if self.messages.count > 0 {
                        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
                    }
                }
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        enterMessageField.endEditing(true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell
        
        cell.chatLogController = self
        
        let msg = messages[indexPath.row]
        cell.message = msg
        cell.textLabel.text = msg.text
        setupCell(cell: cell, msg: msg)
        
        if let text = msg.text {
            cell.sendViewWidthAnchor?.constant = frameForText(text: text).width + 30
            cell.textLabel.isHidden = false
        } else if msg.imageUrl != nil {
            cell.sendViewWidthAnchor?.constant = 200
            cell.textLabel.isHidden = true
        }
        
        if msg.videoUrl != nil {
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatLogCell, msg: Message) {
        
        if let url = self.user?.profileImageUrl {
            cell.profileImageView.loadImagesAndCache(url)
        }
        
        if msg.fromId == FIRAuth.auth()?.currentUser?.uid {
            //blue bubble
            cell.sendView.backgroundColor = ChatLogCell.blueColor
            cell.textLabel.textColor = .white
            cell.profileImageView.isHidden = true
            cell.sendViewRightAnchor?.isActive = true
            cell.sendViewLeftAnchor?.isActive = false
        } else {
            //gray bubble
            cell.sendView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textLabel.textColor = .black
            cell.profileImageView.isHidden = false
            cell.sendViewRightAnchor?.isActive = false
            cell.sendViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = msg.imageUrl {
            cell.messageImageView.loadImagesAndCache(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.sendView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let msg = messages[indexPath.item]
        if let text = msg.text {
            height = frameForText(text: text).height + 20
        } else if let imageWidth = msg.imageWidth?.floatValue, let imageHeight = msg.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    private func frameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    //functions for image zooming
    
    var startFrame: CGRect?
    var blackBg: UIView?
    var startImageView: UIImageView?
    
    func startZoomImageView(startImageView: UIImageView) {
        self.startImageView = startImageView
        self.startImageView?.isHidden = true
        
        startFrame = startImageView.superview?.convert(startImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBg = UIView(frame: keyWindow.frame)
            blackBg?.backgroundColor = .black
            blackBg?.alpha = 0
            keyWindow.addSubview(blackBg!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.blackBg!.alpha = 1
                self.containerView.alpha = 0
                let height = self.startFrame!.height / self.startFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
        
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 20
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startFrame!
                self.blackBg?.alpha = 0
                self.containerView.alpha = 1
                
            }, completion: {(completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startImageView?.isHidden = false
            })
        }
    }
}


























