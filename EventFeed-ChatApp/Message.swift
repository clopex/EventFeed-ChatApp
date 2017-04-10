//
//  Message.swift
//  EventFeed-ChatApp
//
//  Created by MacAir on 4/1/17.
//  Copyright © 2017 MacAir. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl: String?
    
    func chatPartnerId() -> String? {
        
        //short one
        //return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        fromId = dict["fromId"] as? String
        text = dict["text"] as? String
        timestamp = dict["timestamp"] as? NSNumber
        toId = dict["toId"] as? String
        imageUrl = dict["imageUrl"] as? String
        imageHeight = dict["imageHeight"] as? NSNumber
        imageWidth = dict["imageWidth"] as? NSNumber
        
        videoUrl = dict["videoUrl"] as? String
    }
}
