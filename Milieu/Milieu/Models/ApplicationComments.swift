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
    let userId: Int?
    let body: String?
    var createdAt: String = ""
    let voteCount: Int?
    var votedDown: Bool = false
    var votedUp: Bool = false
    var id: Int
    
    init(comment: JSON){
        self.userName = comment["user"]["name"].string ?? "Anonymous"
        self.userId = comment["user"]["id"].int
        self.body = comment["body"].stringValue
        self.createdAt = comment["created_at"].stringValue
        self.voteCount = comment["vote_count"].int
        self.votedDown = comment["voted_down"].boolValue
        self.votedUp = comment["voted_up"].boolValue
        self.id = comment["id"].intValue
    }
}
