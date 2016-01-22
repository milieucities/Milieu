//
//  ApplicationInfo.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import MapKit

/**
 Model class to hold the information relating to one application location, including application #, 
 address, geoLocation and so on.
*/
class ApplicationInfo : MilieuAnnotation{

    let newestStatus: String?
    let newestDate: String?
//    let image: UIImage
    let devId: String?
    let devSiteUid: Int?
    let type: String?
    
    init(devApp: DevApp) {
        let devAppAddress = devApp.addresses?.allObjects.first as? Address
        
        let lat = devAppAddress!.latitude?.doubleValue
        let lon = devAppAddress!.longitude?.doubleValue

        let devAppStatus = devApp.statuses?.allObjects.first as? Status
        newestStatus = devAppStatus?.status
        newestDate = devAppStatus?.statusDate
        devId = devApp.developmentId
        devSiteUid = devApp.id?.integerValue
        type = devApp.applicationType
        
        var appCategory: AnnotationCategory = AnnotationCategory.General
        
        // TODO: Change the status to a NSOrderedSet!
        if let statuses: NSSet = devApp.statuses{
            let array = Array(statuses)
            if array.count > 0{
                if let status = array[0] as? Status{
                    if status.status == "Comment Period in Progress"{
                        appCategory = AnnotationCategory.InComment
                    }
                }
            }
        }
        
        super.init(title: devAppAddress!.street!, category: appCategory, description: devApp.generalDesription!, coordinate: CLLocationCoordinate2DMake(lat!, lon!))
    }
}