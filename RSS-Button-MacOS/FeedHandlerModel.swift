//
//  FeedHandlerModel.swift
//  RSS Button for Safari
//
//  Created by Jan Pingel on 2018-09-28.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Foundation

@objc enum FeedHandlerType: Int, CaseIterable {
    case none = 0
    case app  = 1
    case web  = 2
    case custom = 4
    case copy = 3
}

@objc(FeedHandlerModel)
class FeedHandlerModel: NSObject, NSCoding {    
    let title: String
    let type : FeedHandlerType
    let url  : String?
    let appId: String?
    
    init(title: String, type: FeedHandlerType, url: String?, appId: String?) {
        if (type == FeedHandlerType.app && appId == nil) ||
           ((type == FeedHandlerType.web || type == FeedHandlerType.custom) && url == nil) {
            NSLog("Error: Invalid FeedHandlerModel (\(title))")
        }
        
        self.title = title
        self.type  = type
        self.url   = url
        self.appId = appId
        
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.type  = FeedHandlerType(rawValue: aDecoder.decodeInteger(forKey: "type") as Int)!
        self.url   = aDecoder.decodeObject(forKey: "url") as? String
        self.appId = aDecoder.decodeObject(forKey: "appId") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.type.rawValue, forKey: "type")
        
        if let url = self.url {
            aCoder.encode(url, forKey: "url")
        }
        if let appId = self.appId {
            aCoder.encode(appId, forKey: "appId")
        }
    }
}
