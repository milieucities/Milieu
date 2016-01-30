//
//  DevApp+CoreDataProperties.swift
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

extension DevApp {

    @NSManaged var applicationId: String?
    @NSManaged var developmentId: String?
    @NSManaged var applicationType: String?
    @NSManaged var generalDesription: String?
    @NSManaged var id: NSNumber?
    @NSManaged var neighbourhood: Neighbourhood?
    @NSManaged var addresses: NSSet?
    @NSManaged var statuses: NSOrderedSet?

}
