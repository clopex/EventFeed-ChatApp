//
//  UserDefaultHelpers.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/26/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import Foundation
import UIKit

let FIREBASE_DATABASE_URL = "https://even-chatapp.firebaseio.com/"

extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
    }
    
    func setLogdIn(value: Bool) {
        set(value, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isUserLogIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImagesAndCache(url: String) {
        
        self.image = nil
        
        if let cacheImg = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = cacheImg
            return
        }
        
        let url = URL(string: url)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
            }
              
            DispatchQueue.main.async {
                
                if let downloadImg = UIImage(data: data!) {
                    imageCache.setObject(downloadImg, forKey: url as AnyObject)
                    self.image = downloadImg
                }
            }
            
            
        }).resume()

    }
}
