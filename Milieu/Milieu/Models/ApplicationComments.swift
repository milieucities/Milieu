//
//  ApplicationComments.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-01.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit

struct ApplicationComments {
    let userName: String
    let date: String
    let content: String
    var userAvatar: String = ""
    
    init(userName: String, date: String, content: String, userAvatar: String){
        self.userName = userName
        self.date = date
        self.content = content
        self.userAvatar = userAvatar
    }
    
    
    init(comment: NSDictionary){
        self.userName = comment["username"] as? String ?? "Anonymous"
        self.date = DateUtil.transformStringFromDate(comment["created_at"] as? String, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short, stringFormat: MilieuDateFormat.utcStandardFormat)
        self.content = comment["body"] as? String ?? "Error comment"
    }
}
