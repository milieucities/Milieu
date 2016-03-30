//
//  Neighbourhood+CoreDataProperties.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Neighbourhood {

    @NSManaged var name: String?
    @NSManaged var number: NSNumber?
    @NSManaged var city: City?
    @NSManaged var coordinates: NSSet?
    @NSManaged var devApps: NSSet?

}
