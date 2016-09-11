//
//  Resource.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation


struct Resource<T> {
    let url: NSURL
    let request: NSMutableURLRequest
    let parse: NSData -> T?
}

extension Resource{
    
    init(url: NSURL, parseJSON: AnyObject -> T?){
        self.url = url
        
        // Setup request
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        self.request = request
        
        self.parse = {
            data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}
