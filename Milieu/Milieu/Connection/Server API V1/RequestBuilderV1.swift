//
//  RequestBuilderV1.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-03-29.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

class RequestBuilderV1 {
    var scheme: String?
    var host: String?
    var path: String?
    var header: [String: String]?
    var body: [String: AnyObject]?
    
    typealias BuilderClosure = (RequestBuilderV1) -> ()
    
    init(buildClosure: BuilderClosure){
        buildClosure(self)
    }
    
}

struct Register: CustomStringConvertible{
    
    let url: NSURL
    var header: [String: String] = ["Accept":"application/json",
                                    "Content-Type":"application/json"]
    let body: [String: AnyObject]?
    
    init?(builder: RequestBuilderV1){
        
        if let scheme = builder.scheme, host = builder.host, path = builder.path{
            self.url = NSURL(string: "\(scheme)://\(host)\(path)")!
            
            if let header = builder.header{
                self.header = header
            }
        }else{
            return nil
        }
        
        self.body = builder.body
    }
    
    var description: String{
        return "Register URL: \(url)/nHeader: \(header)/nBody: \(body)"
    }
}