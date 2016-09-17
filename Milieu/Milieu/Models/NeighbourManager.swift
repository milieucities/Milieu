//
//  NeighbourManager.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-19.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import Mapbox

class NeighbourManager{
    static let sharedManager = NeighbourManager()
    var currentNeighbour: Neighbourhood?
    var currentRegion: MKCoordinateRegion?
    
    lazy var neighbourNameSortDescriptor: NSSortDescriptor = {
        var sd = NSSortDescriptor(key: "name", ascending: true)
        return sd
    }()

    
    /**
     Get the distance between two coordinates using Haversine Fomula
     Reference: http://rosettacode.org/wiki/Haversine_formula#Swift
     */
    func calculateLocationDistance(_ topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat1rad = topLeft.latitude * M_PI/180
        let lon1rad = topLeft.longitude * M_PI/180
        let lat2rad = bottomRight.latitude * M_PI/180
        let lon2rad = bottomRight.longitude * M_PI/180
        
        let dLat = lat2rad - lat1rad
        let dLon = lon2rad - lon1rad
        let a1 = sin(dLat/2) * sin(dLat/2)
        let a2 = sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad)
        let a =  a1 + a2
        let c = 2 * asin(sqrt(a))
        let R = 6372.8
        
        return R * c
    }
    
    /**
     Create the expression description for database searching
     
     - Parameter name: The name to find the value in the fetch result
     - Parameter keyPath: The key in the database to search
     - Parameter function: The function to use for caculation
     - Returns: The specific expression description
     */
    class func createExpressionDesc(_ name: String, keyPath: String, function: String) -> NSExpressionDescription{
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = name
        
        expressionDescription.expression = NSExpression(forFunction: function, arguments: [NSExpression(forKeyPath: keyPath)])
        expressionDescription.expressionResultType = .doubleAttributeType
        return expressionDescription
    }
    
    
    func fetchNeighbourhood(_ neighbour: String) -> Neighbourhood?{
        let fetchRequest: NSFetchRequest<Neighbourhood> = NSFetchRequest(entityName: "Neighbourhood")
        let predicate = NSPredicate(format: "name == %@", neighbour)
        fetchRequest.predicate = predicate
        
        do{
            let results = try CoreDataManager.sharedManager.coreDataStack.context.fetch(fetchRequest)
            
            if results.count > 0{
                return results.first!
            }
            
        }catch let error as NSError{
            AR5Logger.debug("ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchNeighbourhoods() -> [Neighbourhood]{
        let fetchRequest: NSFetchRequest<Neighbourhood> = NSFetchRequest(entityName: "Neighbourhood")
        let predicate = NSPredicate(format: "city.name == %@", "OTTAWA")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [neighbourNameSortDescriptor]
        
        do{
            let results = try CoreDataManager.sharedManager.coreDataStack.context.fetch(fetchRequest)
            
            return results
            
        }catch let error as NSError{
            print("ERROR: \(error.localizedDescription)")
            return [Neighbourhood]()
        }
    }
    
    func reset(){
        currentRegion = nil
        currentNeighbour = nil
    }
    
    func setCurrentNeighbourWithName(_ name: String){
        currentNeighbour = fetchNeighbourhood(name)
    }
    
    func setCurrentNeighbourWithObject(_ neighbour: Neighbourhood){
        currentNeighbour = neighbour
    }

}
