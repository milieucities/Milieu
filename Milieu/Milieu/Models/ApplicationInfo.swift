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
    
    override init(devSite: DevSite) {
        super.init(devSite: devSite)
    }
}