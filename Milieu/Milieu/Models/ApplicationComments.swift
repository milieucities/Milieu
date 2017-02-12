//
//  ApplicationComments.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct ApplicationComments {
    var userName: String = "Anonymous"
    let content: String?
    
    init(userName: String = "Anonymous", content: String){
        self.userName = userName
        self.content = content
    }
    
    init(comment: JSON){
        self.userName = comment["user"]["name"].string ?? "Anonymous"
        self.content = comment["body"].stringValue
    }
}
