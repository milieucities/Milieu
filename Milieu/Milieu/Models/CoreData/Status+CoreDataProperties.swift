//
//  Status+CoreDataProperties.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-03-13.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Status {

    @NSManaged var createdDate: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var status: String?
    @NSManaged var statusDate: NSDate?
    @NSManaged var updatedDate: NSDate?
    @NSManaged var devApp: DevApp?

}
