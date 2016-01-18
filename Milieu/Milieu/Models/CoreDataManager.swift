//
//  CoreDataManager.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 1/18/16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation

class CoreDataManager{
    static let sharedManager = CoreDataManager()
    lazy var coreDataStack = CoreDataStack()
}