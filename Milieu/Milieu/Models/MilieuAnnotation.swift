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
    let title: String?
    let category: AnnotationCategory
    let generalDescription: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, category: AnnotationCategory, description: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.category = category
        self.generalDescription = description
        self.coordinate = coordinate
    }
}