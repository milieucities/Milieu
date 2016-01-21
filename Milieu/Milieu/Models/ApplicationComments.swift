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
    let date: NSDate
    let content: String
    let userAvatar: String
    
    init(userName: String, date: NSDate, content: String, userAvatar: String){
        self.userName = userName
        self.date = date
        self.content = content
        self.userAvatar = userAvatar
    }
}

extension ApplicationComments{
    
    
    static func loadAllApplicationComments() -> [ApplicationComments]{
        return loadAllApplicationCommentsFromPlistNamed("Comments")
    }
    
    private static func loadAllApplicationCommentsFromPlistNamed(plistName: String) -> [ApplicationComments]{
        guard
            let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist"),
            let dictionaryArray = NSArray(contentsOfFile: path) as? [[String : AnyObject]]
            else{
                fatalError("An error occurred while reading \(plistName).plist")
        }
        
        var comments = [ApplicationComments]()
        
        for dict in dictionaryArray{
            guard
            let userName = dict["userName"] as? String,
            let userAvatar = dict["userAvatar"] as? String,
            let date = dict["date"] as? NSDate,
            let content = dict["content"] as? String
                else{
                    fatalError("Error parsing dict \(dict)")
            }
            
            let comment = ApplicationComments(
                userName: userName, date: date, content: content, userAvatar: userAvatar)
            
            comments.append(comment)
        }
        return comments
    }
}