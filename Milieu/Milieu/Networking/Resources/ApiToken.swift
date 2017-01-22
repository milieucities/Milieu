//
//  ApiToken.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2017-01-17.
//  Copyright © 2017 Atelier Ruderal. All rights reserved.
//

import Foundation

class ApiToken: NSObject, NSCoding{
    var jwt: String!
    var expireTime: Date!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.jwt = aDecoder.decodeObject(forKey: "jwt") as! String
        self.expireTime = aDecoder.decodeObject(forKey: "expireTime") as! Date
    }
    
    convenience init?(dictionary: JSONDictionary?){
        self.init()
        guard let dictionary = dictionary else {return nil}
        guard let token = dictionary["token"] as? String,
            let expireTime = dictionary["expireTime"] as? Double
            else {return nil}
        self.jwt = token
        self.expireTime = Date(timeIntervalSince1970: expireTime)
    }
    
    func encode(with aCoder: NSCoder) {
        if let jwt = jwt{
            aCoder.encode(jwt, forKey: "jwt")
        }
        if let expireTime = expireTime{
            aCoder.encode(expireTime, forKey: "expireTime")
        }
    }
    
}

// MARK: - Methods
extension ApiToken{
    func isExpire() -> Bool{
        return expireTime <= Date()
    }
    

}
