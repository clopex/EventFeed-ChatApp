//
//  LoginViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

let lastCellId = "lastCellId"
let cellId = "cellId"

protocol LoginControllerDelegate: class {
    func userSignup()
    func imagePicker()
}

class LoginViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, LoginControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var verticalPageControllerConstraint: NSLayoutConstraint?
    var nextButtonConstraint: NSLayoutConstraint?
    var skipButtonConstraint: NSLayoutConstraint?
    
    var testV = LoginCell()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        collectionView?.backgroundColor = .white
        collectionView?.showsHorizontalScrollIndicator = false
        view.addSubview(pageControl)
        view.addSubview(skipBtn)
        view.addSubview(nextBtn)
        
        view.addConstraintWithFormat(format: "H:|[v0]|", views: pageControl)
        verticalPageControllerConstraint = NSLayoutConstraint(item: pageControl, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        
        //view.addConstraintWithFormat(format: "V:[v0]|", views: pageControl)
        
        view.addConstraintWithFormat(format: "H:|-16-[v0]", views: skipBtn)
        skipButtonConstraint = NSLayoutConstraint(item: skipBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)
        //view.addConstraintWithFormat(format: "V:|-20-[v0]", views: skipBtn)
        
        view.addConstraintWithFormat(format: "H:[v0]-16-|", views: nextBtn)
        nextButtonConstraint = NSLayoutConstraint(item: nextBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)
        //view.addConstraintWithFormat(format: "V:|-20-[v0]", views: nextBtn)
        
        view.addConstraints([verticalPageControllerConstraint!, nextButtonConstraint!, skipButtonConstraint!])
    }
    
    fileprivate func registerCells() {
        collectionView?.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(LoginCell.self, forCellWithReuseIdentifier: lastCellId)
    }
    
    let pages: [Page] = {
        
        let page1 = Page(title: "Title about Future", message: "One of the best quotes talking about future, you can find more cool quotes on the world wide web :)", imageName: "intro1")
        let page2 = Page(title: "Title about WallPaper", message: "Some people love wallpaper and some people hate it, but we can all agree there are some very cool images on the net :)", imageName: "intro2")
        let page3 = Page(title: "Title about Success", message: "If you want to become something and someone in your city, or country you must do a lot of things and work hard for it :)", imageName: "intro3")
        
        return [page1, page2, page3]
    }()
    
    lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.pageIndicatorTintColor = UIColor.lightGray
        page.numberOfPages = self.pages.count + 1
        page.currentPageIndicatorTintColor = UIColor.rgb(red: 247, green: 154, blue: 27)
        return page
    }()
    
    lazy var skipBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 247, green: 154, blue: 27), for: .normal)
        button.addTarget(self, action: #selector(skipPage), for: .touchUpInside)
        return button
    }()
    
    lazy var nextBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.rgb(red: 247, green: 154, blue: 27), for: .normal)
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return button
    }()
    
    func skipPage() {
        pageControl.currentPage = pages.count - 1
        nextPage()
    }
    
    func nextPage() {
        
        if pageControl.currentPage == pages.count {
            return
        }
        
        //page before last one
        if pageControl.currentPage == pages.count - 1 {
            animateConstants()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumber
        if pageNumber == pages.count {
            animateConstants()
        } else {
            self.verticalPageControllerConstraint?.constant = 0
            self.nextButtonConstraint?.constant = 20
            self.skipButtonConstraint?.constant = 20
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func animateConstants() {
        self.verticalPageControllerConstraint?.constant = 50
        self.nextButtonConstraint?.constant = -30
        self.skipButtonConstraint?.constant = -30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView?.reloadData()
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pages.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        
        if indexPath.item == pages.count {
            let lastCell = collectionView.dequeueReusableCell(withReuseIdentifier: lastCellId, for: indexPath) as! LoginCell
            lastCell.delegate = self
            lastCell.testAn()
            return lastCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        
        let page = pages[indexPath.item]
        cell.page = page
        return cell
    }
    
    func userSignup() {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        guard let mainVC = rootVC as? MainTabBarController else { return }
        let feedsViewController = FeedsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let navigationController = UINavigationController(rootViewController: feedsViewController)
        navigationController.title = "Event Feeds"
        navigationController.tabBarItem.image = UIImage(named: "newstabbar")
        
        /* treba srediti ovo!!! */
        //creating second, "Follow" ViewController
        let usersNavigationController = UsersViewController()
        let secondNavigationController = UINavigationController(rootViewController: usersNavigationController)
        secondNavigationController.title = "Users"
        secondNavigationController.tabBarItem.image = UIImage(named: "user")
        
        mainVC.viewControllers = [navigationController, secondNavigationController]
        
        UserDefaults.standard.setLogdIn(value: true)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(){
        callAlertViewForImage()
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectImg: UIImage?
        
        if let editImg = info[UIImagePickerControllerCropRect] as? UIImage {
            selectImg = editImg
        } else if let orginalImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectImg = orginalImg
        }
        
        if let image = selectImg {
            let cell = collectionView?.cellForItem(at: NSIndexPath(row: 3, section: 0) as IndexPath) as! LoginCell
            cell.imageView.image = image
        }
        dismiss(animated: true, completion: nil)
        
        
        
    }
    
    func callAlertViewForImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
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

}


























