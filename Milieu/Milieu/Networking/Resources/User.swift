//
//  User.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2017-02-13.
//  Copyright © 2017 Atelier Ruderal. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSObject, NSCoding{
    var id: Int!
    var email: String!
    var name: String!
    var uuid: String!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.id = aDecoder.decodeObject(forKey: "id") as! Int
        self.email = aDecoder.decodeObject(forKey: "email") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
    }
    
    convenience init?(json: JSON){
        self.init()
        self.id = json["id"].intValue
        self.email = json["email"].stringValue
        self.name = json["name"].stringValue
        self.uuid = json["uuid"].stringValue
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(uuid, forKey: "uuid")
    }
}
