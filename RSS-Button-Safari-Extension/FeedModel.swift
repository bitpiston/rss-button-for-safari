//
//  FeedModel.swift
//  RSS Button
//
//  Created by Jan Pingel on 2018-09-23.
//  Copyright © 2018 BitPiston Studios. All rights reserved.
//

import Foundation

class FeedModel: NSObject {
    let title: String
    let type : String
    let url  : String
    
    init(title: String, type: String, url: String) {
        self.title = title
        self.type  = type
        self.url   = url
        
        super.init()
    }
}
