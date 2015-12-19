//
//  ApplicationInfo.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-19.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import MapKit

enum ApplicationType{
    case New
}


/**
 Model class to hold the information relating to one application location, including application #, 
 address, geoLocation and so on.
*/
class ApplicationInfo : NSObject, MKAnnotation{
    let title: String?
    let type: ApplicationType
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D){
        self.title = "New Application"
        self.type = ApplicationType.New
        self.coordinate = coordinate
        
        super.init()
    }
}