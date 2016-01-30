//
//  Status+CoreDataProperties.swift
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

extension Status {

    @NSManaged var statusDate: String?
    @NSManaged var updatedDate: String?
    @NSManaged var status: String?
    @NSManaged var createdDate: String?
    @NSManaged var id: NSNumber?
    @NSManaged var devApp: DevApp?

}
