//
//  Webservice.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

/**
 Networking layer to request and get response from backend
 */
final class Webservice {
    func load<T>(resource: Resource<T>, completion: (T?) -> ()){
        NSURLSession.sharedSession().dataTaskWithRequest(resource.request){
            data, response, error in
            guard let data = data else{
                completion(nil)
                return
            }
            completion(resource.parse(data))
        }.resume()
    }
}
