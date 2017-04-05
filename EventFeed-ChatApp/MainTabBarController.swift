//
//  MainTabBarController.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //check to see if user is ever login to our app, if not present login startUp screen
        
        if isUserLogIn() {
            //user log
            setNavigationControllersForTabBar()
        } else {
            perform(#selector(showLoginControllerView), with: nil, afterDelay: 0.01)
        }

        tabBar.unselectedItemTintColor = .black
        //tabBar.backgroundColor = UIColor.rgb(red: 52, green: 73, blue: 94)
        tabBar.barTintColor = UIColor.rgb(red: 40, green: 83, blue: 136)
        tabBar.isTranslucent = false

    }
    
    fileprivate func setNavigationControllersForTabBar() {
        
        let feedsViewController = FeedsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let navigationController = UINavigationController(rootViewController: feedsViewController)
        navigationController.title = "Event Feeds"
        navigationController.tabBarItem.image = UIImage(named: "newstabbar")
        
        /* treba srediti ovo!!! */
        //creating second, "Follow" ViewController
        let messagesNavVC = MessagesViewController()
        let secondNavigationController = UINavigationController(rootViewController: messagesNavVC)
        secondNavigationController.title = "Inbox"
        secondNavigationController.tabBarItem.image = UIImage(named: "inbox")
//        let usersNavigationController = UsersViewController()
//        let secondNavigationController = UINavigationController(rootViewController: usersNavigationController)
//        secondNavigationController.title = "Users"
//        secondNavigationController.tabBarItem.image = UIImage(named: "user")
        
        viewControllers = [navigationController, secondNavigationController]
    }
    
    fileprivate func isUserLogIn() -> Bool {
        return UserDefaults.standard.isUserLogIn()
    }
    
    func showLoginControllerView() {
        let loginVC = LoginViewController()
        present(loginVC, animated: true, completion: {
            //do something!
        })

    }

}
