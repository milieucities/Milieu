//
//  LaunchViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import CoreData

class LaunchViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var coreDataStack: CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        indicator.hidden = false
        indicator.startAnimating()
        preloadData()
        indicator.stopAnimating()
        indicator.hidden = true
        self.performSegueWithIdentifier("launchToMap", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "launchToMap"{
            let tabBarController = segue.destinationViewController as! UITabBarController
            let mapVC = tabBarController.viewControllers![0] as! MapViewController
            mapVC.coreDataStack = coreDataStack
        }
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
            
            let cityEntity = NSEntityDescription.entityForName("City", inManagedObjectContext: coreDataStack.context)!
            let city = City(entity: cityEntity, insertIntoManagedObjectContext:  coreDataStack.context)
            city.name = "OTTAWA"
            
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
                neighbourhood.city = city
                
                // Get coordinates array
                let geometry = feature["geometry"] as! NSDictionary
                let coordinates = geometry["coordinates"] as! NSArray
                let xyzArrays = coordinates[0] as! NSArray
                
                // Add coordinates into the neighbourhood
                addCoordinatesForNeighbourhood(neighbourhood, coordinates: xyzArrays)
                
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
