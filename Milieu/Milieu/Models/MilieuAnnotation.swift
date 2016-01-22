//
//  MilieuAnnotation.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-21.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import MapKit

enum AnnotationCategory: String{
    case InComment = "commentAnnotation"
    case General = "generalAnnotation"
    case Event = "eventAnnotation"
}

class MilieuAnnotation : NSObject, MKAnnotation{
    let title: String?
    let category: AnnotationCategory
    let generalDescription: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, category: AnnotationCategory, description: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.category = category
        self.generalDescription = description
        self.coordinate = coordinate
    }
}