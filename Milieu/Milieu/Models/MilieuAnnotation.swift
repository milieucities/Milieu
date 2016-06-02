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
    private var _title: String = ""
    var title: String?{
        set{
            _title = newValue ?? ""
        }
        get{
            // Get the first part of the title string
            // i.e. if the title is '70 Richmond Road, Ottawa, Ontario, Canada', then this will only
            // take the '70 Richmond Road'
            return _title.characters.split(",").map(String.init)[0]
        }
    }
    let category: AnnotationCategory
    let generalDescription: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, category: AnnotationCategory, description: String?, coordinate: CLLocationCoordinate2D) {
        
        self.category = category
        self.generalDescription = description
        self.coordinate = coordinate
        
        super.init()
        
        self.title = title
        
    }
}