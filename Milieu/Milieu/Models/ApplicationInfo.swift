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
    let newestDate: NSDate?
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
    var image: UIImage?
    
    init(devApp: DevApp) {
        self.devApp = devApp
        
        let latMid = self.devApp.latitude
        let lonMid = self.devApp.longitude
        let lat = latMid?.doubleValue
        let lon = lonMid?.doubleValue
        

        devId = devApp.developmentId
        devSiteUid = devApp.id?.integerValue
        type = devApp.applicationType
        
        var appCategory: AnnotationCategory = AnnotationCategory.General
        
        for vacant in preDefinedVacants{
            if devId == vacant{
                appCategory = AnnotationCategory.Vacant
            }
        }
        
        let devAppStatus = devApp.statuses?.reverse().first as? Status
        newestStatus = devAppStatus?.status
        newestDate = devAppStatus?.statusDate
        
        if newestStatus == "Comment Period in Progress"{
            appCategory = AnnotationCategory.InComment
        }
        
        
        let address = self.devApp.address
        
        super.init(title: address, category: appCategory, description: devApp.generalDesription, coordinate: CLLocationCoordinate2DMake(lat!, lon!))
    }
}