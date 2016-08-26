//
//  DevSite.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-08-14.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import Mapbox

typealias JSONDictionary = [String: AnyObject]

let url = NSURL(string: "https://milieu.io/dev_sites")!

struct DevSite{
    let id: Int
    let devId: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Static fields
extension DevSite{
    static let all = Resource<[DevSite]>(url: url, parseJSON: { json in
        guard let count = json["total"] as? Int else {return nil}
        guard let dictionaries = json["dev_sites"] as? [JSONDictionary] else {return nil}
        return dictionaries.flatMap(DevSite.init)
    })
    
    static func nearby(coordinate: CLLocationCoordinate2D) -> Resource<[DevSite]>{
        let url = NSURL(string: "https://milieu.io/dev_sites?limit=20&latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)")!
        return Resource(url: url, parseJSON: {
            json in
            guard (json["total"] as? Int) != nil else {return nil}
            guard let dictionaries = json["dev_sites"] as? [JSONDictionary] else {return nil}
            return dictionaries.flatMap(DevSite.init)
        })
    }
}

// MARK: - Constructors
extension DevSite{
    init?(dictionary: JSONDictionary){
        guard let id = dictionary["id"] as? Int,
            devId = dictionary["devID"] as? String,
            latitude = dictionary["latitude"] as? Double,
            longitude = dictionary["longitude"] as? Double
            else {return nil}
        self.id = id
        self.devId = devId
        self.latitude = latitude
        self.longitude = longitude
    }
}