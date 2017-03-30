//
//  ViewController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/20/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase

let feedCellId = "cellId"

//demo JSON url with some random data!
let URL_API = "https://api.myjson.com/bins/87afb"

class FeedsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "logout"), style: .plain, target: self, action: #selector(logOutFromApp)) //UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutFromApp))
        navigationItem.leftBarButtonItem?.tintColor = .white
        //Another way for creating cache for images and access them
        let capacity = 500 * 1024 * 1024
        let cacheForUrls = URLCache(memoryCapacity: capacity, diskCapacity: capacity, diskPath: "randomName")
        URLCache.shared = cacheForUrls
        
        getDataFromJsonApi()

        
        navigationItem.title = "Event Feeds"
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.showsVerticalScrollIndicator = false
        
        //we must registar class for the collectionView
        collectionView?.register(FeedsCell.self, forCellWithReuseIdentifier: feedCellId)
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
    
    func getDataFromJsonApi() {
        
        let urlRequest = URL(string: URL_API)
        URLSession.shared.dataTask(with: urlRequest!) { (data, response, error) in
            
            if error != nil {
                print(error!)
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                
                if let postsArray = json["posts"] as? [[String: AnyObject]] {
                    
                    self.events = [Event]()
                    
                    for dic in postsArray {
                        let post = Event()
                        post.setValuesForKeys(dic)
                        self.events.append(post)
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch let jsonErr {
                print(jsonErr)
            }
            
            
            }.resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellId, for: indexPath) as! FeedsCell
        
        //this will call didSet function from FeedCell without need of if let bellow!
        cell.event = events[indexPath.item]
        
        //reference to var feedVC
        cell.eventVC = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //calucate dynamic size of the cell, because article text is differetn from one autor to another
        if let statusText = events[indexPath.item].articleText {
            let rect = NSString(string: statusText).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            
            //this are the sum of the values from the constraint we define down bellow for each widget
            let realHeightFromConstratin: CGFloat = 8 + 44 + 4 + 4 + 200 + 8 + 24 + 8 + 44
            
            //additional 24 is just for looking nicee :)
            return CGSize(width: view.frame.width, height: rect.height + realHeightFromConstratin + 24)
        }
        
        return CGSize(width: view.frame.width, height: 400)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //rearrange layout when user rotate device
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //declare background view so we can hide everything else expect image
    let blackBGView = UIView()
    
    var statusImageView: UIImageView?
    
    let bottomTabBar = UIView()
    let topNavBar = UIView()
    let viewAnime = UIImageView()
    
    //animate ImageView
    func animateImageView(statusImageView: UIImageView) {
        
        self.statusImageView = statusImageView
        
        let startFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil)
        
        //hide main image when user tap on the image
        statusImageView.alpha = 0
        
        //make BG same size as main View and make it black
        blackBGView.frame = self.view.frame
        blackBGView.backgroundColor = UIColor.black
        blackBGView.alpha = 0
        view.addSubview(blackBGView)
        
        //fade out top navigation bar, with size
        topNavBar.frame = CGRect(x: 0, y: 0, width: 1000, height: 20 + 44)
        topNavBar.backgroundColor = UIColor.black
        topNavBar.alpha = 0
        
        
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(topNavBar)
            bottomTabBar.frame = CGRect(x: 0, y: keyWindow.frame.height - 49, width: 1000, height: 49)
            bottomTabBar.backgroundColor = UIColor.black
            bottomTabBar.alpha = 0
            keyWindow.addSubview(bottomTabBar)
        }
        
        viewAnime.backgroundColor = UIColor.red
        viewAnime.frame = startFrame!
        viewAnime.isUserInteractionEnabled = true
        viewAnime.image = statusImageView.image
        viewAnime.contentMode = .scaleAspectFill
        viewAnime.clipsToBounds = true
        view.addSubview(viewAnime)
        
        viewAnime.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedsViewController.zoomToDefault)))
        
        //animation with some cool Damping...
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.55, options: .curveEaseOut, animations: {
            let height = (self.view.frame.width / (startFrame?.width)!) * (startFrame?.height)!
            let y = self.view.frame.height / 2 - height / 2
            self.viewAnime.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.blackBGView.alpha = 1
            
            //make top navigation bar visible again
            self.topNavBar.alpha = 1
            
            self.bottomTabBar.alpha = 1
            
        }, completion: nil)
    }
    
    func zoomToDefault() {
        if let startFrame = statusImageView?.superview?.convert((statusImageView?.frame)!, to: nil) {
            
            //cool animation with nice Damping animation :)
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.55, options: .curveEaseIn, animations: {
                self.viewAnime.frame = startFrame
                self.blackBGView.alpha = 0
                self.topNavBar.alpha = 0
                self.bottomTabBar.alpha = 0
            }, completion: { (didComplete) in
                self.viewAnime.removeFromSuperview()
                self.blackBGView.removeFromSuperview()
                self.topNavBar.removeFromSuperview()
                self.bottomTabBar.removeFromSuperview()
                self.statusImageView?.alpha = 1
            })
        }
    }


}

