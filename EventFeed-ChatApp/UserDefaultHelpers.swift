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
