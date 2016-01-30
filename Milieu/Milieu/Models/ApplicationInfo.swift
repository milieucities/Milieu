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
    let devApp: DevApp
    let preDefinedVacants = ["D07-12-14-0197","D01-01-13-0003","D01-01-14-0021","D07-12-13-0119",
        "D01-01-14-0020","D07-05-15-0005","D07-12-14-0194","D02-02-13-0042","D07-12-14-0169",
        "D07-12-15-0050","D01-01-14-0026","D02-02-15-0019","D07-05-15-0006","D07-05-15-0001",
        "D02-02-14-0143","D07-12-15-0119","D02-02-15-0026","D02-02-15-0044","D07-12-15-0081",
        "D02-02-15-0019","D07-12-15-0086","D07-16-15-0003"]
    
    init(devApp: DevApp) {
        self.devApp = devApp
        let devAppAddress = devApp.addresses?.allObjects.first as? Address
        
        let lat = devAppAddress!.latitude?.doubleValue
        let lon = devAppAddress!.longitude?.doubleValue

        let devAppStatus = devApp.statuses?.firstObject as? Status
        newestStatus = devAppStatus?.status
        newestDate = devAppStatus?.statusDate
        devId = devApp.developmentId
        devSiteUid = devApp.id?.integerValue
        type = devApp.applicationType
        
        var appCategory: AnnotationCategory = AnnotationCategory.General
        
        
        // TODO: Change the status to a NSOrderedSet!
        if let statuses: NSOrderedSet = devApp.statuses{
            let array = Array(statuses)
            if array.count > 0{
                if let status = array[array.count-1] as? Status{
                    if status.status == "Comment Period in Progress"{
                        appCategory = AnnotationCategory.InComment
                    }
                }
            }
        }
        
        for vacant in preDefinedVacants{
            if devId == vacant{
                appCategory = AnnotationCategory.Vacant
            }
        }
        
        if type == "Demolition Control"{
            appCategory = AnnotationCategory.Vacant
        }
        
        let address = devAppAddress?.street
        
        super.init(title: address, category: appCategory, description: devApp.generalDesription, coordinate: CLLocationCoordinate2DMake(lat!, lon!))
    }
}