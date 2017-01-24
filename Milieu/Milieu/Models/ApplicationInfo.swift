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
    
    let devSite: DevSite!
    var cacheSmallImage: UIImage?
    
    init(devSite: DevSite) {
        self.devSite = devSite
        super.init(coordinate: CLLocationCoordinate2DMake(devSite.latitude, devSite.longitude))
        category = AnnotationCategory.General
    }
}
