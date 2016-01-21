//
//  ApplicationInfo.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import MapKit

enum ApplicationType: String{
    case OfficeBuilding = "office-building.png"
    case Construction = "constructioncrane.png"
    case Demolition = "demolition.png"
}


/**
 Model class to hold the information relating to one application location, including application #, 
 address, geoLocation and so on.
*/
class ApplicationInfo : NSObject, MKAnnotation{
    let title: String?
    let type: String?
    let newestStatus: String?
    let newestDate: String?
//    let image: UIImage
    let generalDescription: String?
    let coordinate: CLLocationCoordinate2D
    let devId: String?
    
    init(devApp: DevApp) {
        // Set the title
        generalDescription = devApp.generalDesription
        type = devApp.applicationType
        let devAppStatus = devApp.statuses?.allObjects.first as? Status
        newestStatus = devAppStatus?.status
        newestDate = devAppStatus?.statusDate
        devId = devApp.developmentId
        
        let devAppAddress = devApp.addresses?.allObjects.first as? Address
        title = devAppAddress!.street!
        let lat = devAppAddress!.latitude?.doubleValue
        let lon = devAppAddress!.longitude?.doubleValue
        coordinate = CLLocationCoordinate2DMake(lat!, lon!)
    }
}