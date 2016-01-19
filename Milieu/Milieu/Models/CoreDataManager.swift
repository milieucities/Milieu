//
//  CoreDataManager.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 1/18/16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CoreDataManager{
    static let sharedManager = CoreDataManager()
    lazy var coreDataStack = CoreDataStack()
    
    // MARK: - Manipulate neighbour data
    func regionForSelectedNeighbourhood(neighbour: String) -> MKCoordinateRegion?{
        
        // Create the fetch request for the coordinate entity
        let fetchRequest = NSFetchRequest(entityName: "Coordinate")
        let predicate = NSPredicate(format: "neighbourhood.name == %@", neighbour)
        fetchRequest.predicate = predicate
        fetchRequest.resultType = .DictionaryResultType
        
        
        let minLatExpressionDesc = createExpressionDesc("minLat", keyPath: "latitude", function: "min:")
        let minLonExpressionDesc = createExpressionDesc("minLon", keyPath: "longitude", function: "min:")
        let maxLatExpressionDesc = createExpressionDesc("maxLat", keyPath: "latitude", function: "max:")
        let maxLonExpressionDesc = createExpressionDesc("maxLon", keyPath: "longitude", function: "max:")
        
        fetchRequest.propertiesToFetch = [minLatExpressionDesc, minLonExpressionDesc, maxLatExpressionDesc, maxLonExpressionDesc]
        
        do{
            // Fetch the coordinates belongs to this neighbourhood
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSDictionary]
            let resultDict = results.first!
            let minLat = resultDict["minLat"] as! CLLocationDegrees
            let minLon = resultDict["minLon"] as! CLLocationDegrees
            let maxLat = resultDict["maxLat"] as! CLLocationDegrees
            let maxLon = resultDict["maxLon"] as! CLLocationDegrees
            
            // For Ottawa, minLat is lower and maxLat is upper, minLon is left and maxLon is right
            let topLeftCoordinate = CLLocationCoordinate2DMake(maxLat, minLon)
            let topRightCoordinate = CLLocationCoordinate2DMake(maxLat, maxLon)
            let bottomLeftCoordinate = CLLocationCoordinate2DMake(minLat, minLon)
            
            let midCoordinate = CLLocationCoordinate2DMake((minLat+maxLat)/2, (minLon+maxLon)/2)
            
            let latDistance = calculateLocationDistance(topLeftCoordinate, bottomRight: topRightCoordinate) * 1000
            let lonDistance = calculateLocationDistance(topLeftCoordinate, bottomRight: bottomLeftCoordinate) * 1000
            
            print("The distance: \(latDistance), \(lonDistance)")
            
            let region = MKCoordinateRegionMakeWithDistance(midCoordinate, latDistance, lonDistance)
            
            // Alternative region populate method. Need to test wthich is better
            
            //            let midCoordinate = CLLocationCoordinate2DMake(45.268572, -75.741772)
            //            let latDelta = topLeftCoordinate.latitude - bottomRightCoordinate.latitude
            //            let lonDelta = topLeftCoordinate.longitude - bottomRightCoordinate.longitude
            //            let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
            //            let region = MKCoordinateRegionMake(midCoordinate, span)
            
            return region
            
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch coordinates: \(error), \(error.userInfo)")
        }
        return nil
    }
    
    /**
     Get the distance between two coordinates using Haversine Fomula
     Reference: http://rosettacode.org/wiki/Haversine_formula#Swift
     */
    func calculateLocationDistance(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) -> CLLocationDistance{
        let lat1rad = topLeft.latitude * M_PI/180
        let lon1rad = topLeft.longitude * M_PI/180
        let lat2rad = bottomRight.latitude * M_PI/180
        let lon2rad = bottomRight.longitude * M_PI/180
        
        let dLat = lat2rad - lat1rad
        let dLon = lon2rad - lon1rad
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad)
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
    func createExpressionDesc(name: String, keyPath: String, function: String) -> NSExpressionDescription{
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = name
        
        expressionDescription.expression = NSExpression(forFunction: function, arguments: [NSExpression(forKeyPath: keyPath)])
        expressionDescription.expressionResultType = .DoubleAttributeType
        return expressionDescription
    }

    
    func fetchNeighbourhood(neighbour: String) -> Neighbourhood?{
        let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
        let predicate = NSPredicate(format: "name == %@", neighbour)
        fetchRequest.predicate = predicate
        
        do{
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Neighbourhood]
            
            if results.count > 0{
                return results.first!
            }
            
        }catch let error as NSError{
            AR5Logger.debug("ERROR: \(error.localizedDescription)")
        }
        
        return nil
    }

}