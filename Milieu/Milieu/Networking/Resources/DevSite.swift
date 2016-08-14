//
//  DevSite.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: AnyObject]

let url = NSURL(string: "https://milieu.io/dev_sites")!

struct DevSite{
    let id: Int
    let devId: String
}

// MARK: - Static fields
extension DevSite{
    static let all = Resource<[DevSite]>(url: url, parseJSON: { json in
        guard let count = json["total"] as? Int else {return nil}
        guard let dictionaries = json["dev_sites"] as? [JSONDictionary] else {return nil}
        return dictionaries.flatMap(DevSite.init)
    })
}

// MARK: - Constructors
extension DevSite{
    init?(dictionary: JSONDictionary){
        guard let id = dictionary["id"] as? Int,
            devId = dictionary["devID"] as? String
            else {return nil}
        self.id = id
        self.devId = devId
    }
}