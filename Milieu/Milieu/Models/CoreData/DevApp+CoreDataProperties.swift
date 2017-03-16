//
//  DevApp+CoreDataProperties.swift
//  
//
//  Created by Xiaoxi Pang on 2016-07-27.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DevApp {

    @NSManaged var applicationId: String?
    @NSManaged var applicationType: String?
    @NSManaged var developmentId: String?
    @NSManaged var generalDesription: String?
    @NSManaged var id: NSNumber?
    @NSManaged var imageUrl: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var address: String?
    @NSManaged var addresses: NSSet?
    @NSManaged var neighbourhood: Neighbourhood?
    @NSManaged var statuses: NSOrderedSet?

}
