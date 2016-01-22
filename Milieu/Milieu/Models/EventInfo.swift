//
//  EventInfo.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-22.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import MapKit

class EventInfo: MilieuAnnotation {

    let address1: String?
    let address2: String?
    //    let image: UIImage
    let time: String?
    let email: String?
    let telephone: String?
    let wardNum: Int?
    let wardName: String?
    
    init(dict: [String : AnyObject]) {
        let title = dict["title"] as? String
        
        let lat = Double(dict["latitude"] as! String)
        let lon = Double(dict["longitude"] as! String)

        let appCategory: AnnotationCategory = AnnotationCategory.Event
        let generalDescription = dict["generalDescription"] as? String
        address1 = dict["address1"] as? String
        address2 = dict["address2"] as? String
        time = dict["time"] as? String
        email = dict["email"] as? String
        telephone = dict["telephone"] as? String
        wardNum = (dict["wardNum"] as? NSNumber)?.integerValue
        wardName = dict["wardName"] as? String
        
        super.init(title: title!, category: appCategory, description: generalDescription!, coordinate: CLLocationCoordinate2DMake(lat!, lon!))
    }

}

extension EventInfo{
    
    static func loadAllEvents() -> [EventInfo]{
        return loadAllEventsFromPlistNamed("Events")
    }
    
    private static func loadAllEventsFromPlistNamed(plistName: String) -> [EventInfo]{
        guard
            let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist"),
            let dictionaryArray = NSArray(contentsOfFile: path) as? [[String : AnyObject]]
            else{
                fatalError("An error occurred while reading \(plistName).plist")
        }
        
        var events = [EventInfo]()
        
        for dict in dictionaryArray{
            
            let event = EventInfo(dict: dict)
            
            events.append(event)
        }
        return events
    }

}
