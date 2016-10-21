//
//  MilieuAnnotation.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-21.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import Mapbox

enum AnnotationCategory: String{
    case InComment = "commentAnnotation"
    case Vacant = "vacantAnnotation"
    case General = "generalAnnotation"
    case Event = "eventAnnotation"
}

class MilieuAnnotation : NSObject, MGLAnnotation{	

    let coordinate: CLLocationCoordinate2D
    var category: AnnotationCategory = AnnotationCategory.General
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}