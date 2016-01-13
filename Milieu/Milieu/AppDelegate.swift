//
//  AppDelegate.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        preloadData()
        
        let tabBarController = self.window!.rootViewController as! UITabBarController
        let viewController = tabBarController.viewControllers![0] as! MapViewController
        viewController.coreDataStack = coreDataStack
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(DefaultsKey.Location)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func preloadData(){
        let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
        fetchRequest.resultType = .CountResultType
        
        do{
            // Check the neighbourhood objects count
           let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
            
            // If there is no data, load json file in
            if results.first!.integerValue == 0{
                preloadWardsDataIfNeeded()
            }
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
        }
    }

    /**
     load and parse wards geojson file
     */
    func preloadWardsDataIfNeeded(){
        
        // Find json file path
        let jsonURL = NSBundle.mainBundle().URLForResource("ottawa_wards_2010", withExtension: "json")!
        
        // Load json data
        let jsonData = NSData(contentsOfURL: jsonURL)!
        
        do{
            // Parse JSON data
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! NSDictionary
            let features = jsonDictionary["features"] as! NSArray
            
            // Create entity description
            let entity = NSEntityDescription.entityForName("Neighbourhood", inManagedObjectContext: coreDataStack.context)!
            
            for feature in features{
                let properties = feature["properties"] as! NSDictionary
                let wardNumber = Int(properties["WARD_NUM"] as! String)!
                let wardName = properties["DESCRIPTIO"] as! String
                
                // Create entity
                let neighbourhood = Neighbourhood(entity: entity, insertIntoManagedObjectContext: coreDataStack.context)
                neighbourhood.name = wardName
                neighbourhood.number = NSNumber(integer: wardNumber)
                
                // Get coordinates array
                let geometry = feature["geometry"] as! NSDictionary
                let coordinates = geometry["coordinates"] as! NSArray
                let xyzArrays = coordinates[0] as! NSArray
                
                // Add coordinates into the neighbourhood
                addCoordinatesForNeighbourhood(neighbourhood, coordinates: xyzArrays)

                coreDataStack.saveContext()
                coreDataStack.context.reset()
            }
            
            coreDataStack.saveContext()
            coreDataStack.context.reset()
            
        }catch let error as NSError{
            AR5Logger.debug("Error: \(error.localizedDescription)")
            abort()
        }
    }
    
    /**
     Add coordinates into the Coordinate object
     
     - Parameter neighbourhood: The parent neighbourhood that the coordinate belongs to
     - Parameter coordinates: The coordinate array need to save in
    */
    func addCoordinatesForNeighbourhood(neighbourhood: Neighbourhood, coordinates: NSArray){
        
        for xyz in coordinates{
            let coordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: coreDataStack.context) as! Coordinate
            coordinate.longitude = NSNumber(double: xyz[0] as! Double)
            coordinate.latitude = NSNumber(double: xyz[1] as! Double)
            coordinate.neighbourhood = neighbourhood
        }
    }
}

