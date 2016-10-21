//
//  Resource.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation


struct Resource<T> {
    let url: URL
    let request: URLRequest
    let parse: (Data) -> T?
}

extension Resource{
    
    init(url: URL, parseJSON: @escaping ([String:AnyObject]?) -> T?){
        self.url = url
        
        // Setup request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        self.request = request
        
        self.parse = {
            data in
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            return json.flatMap(parseJSON)
        }
    }
}
