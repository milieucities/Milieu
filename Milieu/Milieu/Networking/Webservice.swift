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
    func load<A>(resource: Resource<A>, completion: @escaping (A?) -> ()) {
        let request = NSMutableURLRequest(resource: resource)
        URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            completion(data.flatMap(resource.parse))
            }.resume()
    }
}

extension NSMutableURLRequest {
    convenience init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
        httpMethod = resource.method.method
        addValue("application/json", forHTTPHeaderField: "Accept")
        if case let .post(data) = resource.method {
            httpBody = data
        }
    }
}
