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

    @NSManaged var createdDate: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var status: String?
    @NSManaged var statusDate: Date?
    @NSManaged var updatedDate: Date?
    @NSManaged var devApp: DevApp?

}
