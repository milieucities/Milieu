//
//  LaunchViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-01-16.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class LaunchViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var coreDataStack: CoreDataStack!
    
    var neighbourhoods: [Neighbourhood]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        indicator.hidden = false
        indicator.startAnimating()
        preloadData()
        }
    
    /**
     Preload all required data either from the data base or server connection
    */
    func preloadData(){
        // Find or Create Neighbourhood Data
        let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
        fetchRequest.resultType = .CountResultType
        
        do{
            // Check the neighbourhood objects count
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
            
            // If there is no data, load json file in
            if results.first!.integerValue == 0{
                preloadWardsData()
            }else{
                // CHeck the devapp objects count
                let fetchRequest = NSFetchRequest(entityName: "DevApp")
                fetchRequest.resultType = .CountResultType
                let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [NSNumber]
                if results.first!.integerValue == 0{
                    preloadApplictionsIfNeeded()
                }else{
                    finishPreload()
                }
            }
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
        }

        // Fetch Applications data from server and save into the CoreData
//        preloadApplictionsIfNeeded()
    }
    
    /**
     Finish the preloading process, stop the indicator and segue to the next view controller
    */
    func finishPreload(){
        indicator.stopAnimating()
        indicator.hidden = true
        self.performSegueWithIdentifier("launchToMap", sender: self)
    }
    
    // MARK: - Preload Neighbourhood Data
    /**
     load and parse wards geojson file
     */
    func preloadWardsData(){
        
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

    // MARK: - Preload Application Data
    func preloadApplictionsIfNeeded(){
        fetchDevAppsFromServer()
    }
    
    /**
     Use Alamofire for the data fetching
    */
    func fetchDevAppsFromServer(){
        let headers = ["Accept": "application/json"]
        let serverUrl = "http://159.203.32.15"
        
        Alamofire.request(.GET, NSURL(string: "\(serverUrl)\(RequestType.FetchAllApplications.rawValue)")!, headers: headers).responseJSON{
            response in
            
            debugPrint(response.result.error)
            debugPrint(response.response)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let result = response.result.value{
                    self.handleDevAppResults(result)
                }
                
                self.finishPreload()
            })
        }
    }
    
    func handleDevAppResults(result: AnyObject){
        
        let siteApps = (result[0] as! NSDictionary)["siteApps"] as! NSDictionary
        
        for i in 1...siteApps.count{
            if let app = siteApps["\(i-1)"] as? NSDictionary{
                if let wardNum: Int = app["ward_num"] as? Int {
                    let appObject = NSEntityDescription.insertNewObjectForEntityForName("DevApp", inManagedObjectContext: coreDataStack.context) as! DevApp
                    appObject.applicationId = app["application_id"] as? String
                    appObject.applicationType = app["application_type"] as? String
                    appObject.developmentId = app["development_id"] as? String
                    appObject.id = NSNumber(integer: (app["id"] as? Int)!)
                    appObject.generalDesription = app["description"] as? String
                    addAddressesForDevApp(appObject, addresses: app["addresses"] as! NSArray)
                    addStatusesForDevApp(appObject, statuses: app["statuses"] as! NSArray)
                    addDevAppInNeighbourhood(appObject, withWardNum: wardNum)
                }
            }
        }
    }
    
    /**
     Add addresses into the DevApp object
     
     - Parameter devApp: The parent DevApp that the addresses belongs to
     - Parameter addresses: The addresses array need to save in
     */
    func addAddressesForDevApp(devApp: DevApp, addresses: NSArray){
        
        for address in addresses{
            if let lat = address["lat"] as? Double, let lon = address["lon"] as? Double, let street = address["street"] as? String{
                let addressObject = NSEntityDescription.insertNewObjectForEntityForName("Address", inManagedObjectContext: coreDataStack.context) as! Address
                addressObject.id = NSNumber(integer: (address["id"] as? Int)!)
                addressObject.latitude = NSNumber(double: lat)
                addressObject.longitude = NSNumber(double: lon)
                addressObject.street = street
                addressObject.createdDate = address["created_at"] as? String
                addressObject.updatedDate = address["updated_at"] as? String
                addressObject.devApp = devApp
            }
        }
    }

    
    /**
     Add statuses into the DevApp object
     
     - Parameter devApp: The parent DevApp that the statuses belongs to
     - Parameter statuses: The statuses array need to save in
     */
    func addStatusesForDevApp(devApp: DevApp, statuses: NSArray){
        
        for status in statuses{
            let statusObject = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: coreDataStack.context) as! Status
            statusObject.id = NSNumber(integer: (status["id"] as? Int)!)
            statusObject.status = status["status"] as? String
            statusObject.createdDate = status["created_at"] as? String
            statusObject.statusDate = status["status_date"] as? String
            statusObject.updatedDate = status["updated_at"] as? String
            statusObject.devApp = devApp
        }
    }

    
    func addDevAppInNeighbourhood(appObject: DevApp, withWardNum wardNum: Int){
        // Find or Create Neighbourhood Data
        let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
        let predicate = NSPredicate(format: "number == %@", NSNumber(integer: wardNum))
        fetchRequest.predicate = predicate
        
        do{
            // Check the neighbourhood objects count
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Neighbourhood]
            
            // If there is no data, load json file in
            if results.count > 0{
                let neighbourhood = results.first!
                let devApps = neighbourhood.devApps!.mutableCopy() as! NSMutableSet
                devApps.addObject(appObject)
                neighbourhood.devApps = devApps.copy() as? NSSet
            }
            
            coreDataStack.saveContext()
            coreDataStack.context.reset()
            
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
        }
    }
}

