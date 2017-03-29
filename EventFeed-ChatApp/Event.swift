//
//  Even.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 3/21/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit

class Event: NSObject {
    var name: String?
    var articleText: String?
    var profileImageName: String?
    var articleImageName: String?
    var numberOfComments: NSNumber?
    var numberOfLikes: NSNumber?
    var date: String?
    
    var location: Location?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "location" {
            location = Location()
            location?.setValuesForKeys(value as! [String: AnyObject])
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
}

class Location: NSObject {
    var city: String?
    var state: String?
}
