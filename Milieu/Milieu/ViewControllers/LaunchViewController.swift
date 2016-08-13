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
    var privateContext: NSManagedObjectContext!
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        indicator.hidden = false
        indicator.startAnimating()
        self.navigationController?.navigationBar.translucent = true
        informationLabel.text = "Getting the map from the bookshelf ..."
        privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = coreDataStack.context.persistentStoreCoordinator
        privateContext.performBlock{
            self.preloadData()
        }
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
            let results = try self.privateContext.executeFetchRequest(fetchRequest) as! [NSNumber]
            
            // If there is no data, load json file in
            if results.first!.integerValue == 0{
                preloadWardsData()
            }else{
                // Check the devapp objects count
                let fetchRequest = NSFetchRequest(entityName: "DevApp")
                fetchRequest.resultType = .CountResultType
                let results = try self.privateContext.executeFetchRequest(fetchRequest) as! [NSNumber]
                if results.first!.integerValue == 0{
                    preloadApplictionsIfNeeded()
                }else{
                    finishPreload()
                }
            }
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
            dispatch_async(dispatch_get_main_queue(), {
                self.informationLabel.text = "Oops! A fatal error occurs ..."
            })
        }
    }
    
    /**
     Finish the preloading process, stop the indicator and segue to the next view controller
     */
    func finishPreload(){
        dispatch_async(dispatch_get_main_queue(), {
            self.indicator.stopAnimating()
            self.indicator.hidden = true
            self.performSegueWithIdentifier("launchToMap", sender: self)
        })
    }
    
    // MARK: - Preload Neighbourhood Data
    /**
    load and parse wards geojson file
    */
    func preloadWardsData(){
        insertWardsDataFromApi()
    }
    
    func insertWardsDataFromApi(){
        
        // TODO: change to fetch wards page by page.
        Alamofire.request(.GET, NSURL(string: "\(Connection.OpenNorthBaseUrl)\(OpenNorthApi.FindOttawaWards.rawValue)")!).responseJSON{
            response in
            
            if let _ = response.result.error{
                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.text = "Oops! Can not find the secret path, \nrelaunch the app pls ..."
                })
                AR5Logger.debug("\(response.result.error?.userInfo)")
                return
            }
            
            if let result = response.result.value{
                self.privateContext.performBlock{
                    self.parseWardsFromDict(result as! [String: AnyObject])
                }
              
            }
        }
    }
    
    func parseWardsFromDict(dict: [String: AnyObject]){
        let wards = dict["objects"] as! [[String: AnyObject]]
        // TODO: If the coredata city wards count is less than Api returned wards count, update the coredata
        
        // Create city in the CoreData
        let cityEntity = NSEntityDescription.entityForName("City", inManagedObjectContext: self.privateContext)!
        let city = City(entity: cityEntity, insertIntoManagedObjectContext:  privateContext)
        city.name = "OTTAWA"
        
        // Create entity description
        let entity = NSEntityDescription.entityForName("Neighbourhood", inManagedObjectContext: self.privateContext)!
        
        dispatch_async(dispatch_get_main_queue(), {
            self.informationLabel.text = "Desgining the blueprint ..."
            self.percentLabel.hidden = false
            self.percentLabel.text = "0 %"
        })
        
        for ward in wards{
            let wardNumber = Int(ward["external_id"] as! String)!
            let wardName = ward["name"] as! String
            
            // Create entity
            let neighbourhood = Neighbourhood(entity: entity, insertIntoManagedObjectContext: self.privateContext)
            neighbourhood.name = wardName
            neighbourhood.number = NSNumber(integer: wardNumber)
            neighbourhood.city = city
        }
        
        do{
            try self.privateContext.save()
            self.privateContext.reset()
            insertWardBoundsFromApi()
        }catch let error as NSError{
            AR5Logger.debug("Error: \(error.localizedDescription)")
            dispatch_async(dispatch_get_main_queue(), {
                self.informationLabel.text = "Oops! A fatal error occurs ..."
            })
        }
    }
    
    func insertWardBoundsFromApi(){
        // TODO: change to fetch wards page by page.
        Alamofire.request(.GET, NSURL(string: "\(Connection.OpenNorthBaseUrl)\(OpenNorthApi.FindOttawaWardsSimpleShape.rawValue)")!).responseJSON{
            response in
            
            if let _ = response.result.error{
                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.text = "Oops! Can not find the secret path, \nrelaunch the app pls ..."
                })
                AR5Logger.debug("\(response.result.error?.userInfo)")
                return
            }
            
            if let result = response.result.value{
                self.privateContext.performBlock{
                    self.parseBoundariesFromDict(result as! [String: AnyObject])
                }
            }
        }
    }
    
    func parseBoundariesFromDict(dict: [String: AnyObject]){
        let boundaries = dict["objects"] as! [[String: AnyObject]]
        
        var count = 0
        for boundary in boundaries{
            
            let simpleShape = boundary["simple_shape"] as! [String: AnyObject]
            let coordinates = ((simpleShape["coordinates"] as! NSArray)[0] as! NSArray)[0] as! NSArray
            
            // Find or Create Neighbourhood Data
            let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
            let predicate = NSPredicate(format: "name == %@", (boundary["name"] as! String))
            fetchRequest.predicate = predicate
            
            do{
                // Check the neighbourhood objects count
                let results = try self.privateContext.executeFetchRequest(fetchRequest) as! [Neighbourhood]
                
                // If there is no data, load json file in
                if results.count > 0{
                    let neighbourhood = results.first!
                    
                    addCoordinatesForNeighbourhood(neighbourhood, coordinates: coordinates)
                }
                
                try self.privateContext.save()
                self.privateContext.reset()
                
                count += 1
                dispatch_async(dispatch_get_main_queue(), {
                    self.percentLabel.text = "\(Int (count * 100 / boundaries.count)) %"
                })
                
            }catch let error as NSError{
                AR5Logger.debug("Error: \(error.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.text = "Oops! A fatal error occurs ..."
                })
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.percentLabel.hidden = true
        })
        
        preloadApplictionsIfNeeded()
    }
    
    func insertWardsDataFromJson(){
        
        // Find json file path
        let jsonURL = NSBundle.mainBundle().URLForResource("ottawa_wards_2010", withExtension: "json")!
        
        // Load json data
        let jsonData = NSData(contentsOfURL: jsonURL)!
        
        do{
            // Parse JSON data
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! NSDictionary
            let features = jsonDictionary["features"] as! NSArray
            
            let cityEntity = NSEntityDescription.entityForName("City", inManagedObjectContext: self.privateContext)!
            let city = City(entity: cityEntity, insertIntoManagedObjectContext:  privateContext)
            city.name = "OTTAWA"
            
            // Create entity description
            let entity = NSEntityDescription.entityForName("Neighbourhood", inManagedObjectContext: self.privateContext)!
            
            dispatch_async(dispatch_get_main_queue(), {
                self.informationLabel.text = "Desgining the blueprint ..."
                self.percentLabel.hidden = false
                self.percentLabel.text = "0 %"
            })
            var count = 0
            for feature in features{
                let properties = feature["properties"] as! NSDictionary
                let wardNumber = Int(properties["WARD_NUM"] as! String)!
                let wardName = properties["DESCRIPTIO"] as! String
                
                // Create entity
                let neighbourhood = Neighbourhood(entity: entity, insertIntoManagedObjectContext: self.privateContext)
                neighbourhood.name = wardName
                neighbourhood.number = NSNumber(integer: wardNumber)
                neighbourhood.city = city
                
                // Get coordinates array
                let geometry = feature["geometry"] as! NSDictionary
                let coordinates = geometry["coordinates"] as! NSArray
                let xyzArrays = coordinates[0] as! NSArray
                
                // Add coordinates into the neighbourhood
                addCoordinatesForNeighbourhood(neighbourhood, coordinates: xyzArrays)
                count += 1
                dispatch_async(dispatch_get_main_queue(), {
                    self.percentLabel.text = "\(Int (count * 100 / features.count)) %"
                })
            }
            
            try self.privateContext.save()
            self.privateContext.reset()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.percentLabel.hidden = true
            })
            
            preloadApplictionsIfNeeded()
        }catch let error as NSError{
            AR5Logger.debug("Error: \(error.localizedDescription)")
            dispatch_async(dispatch_get_main_queue(), {
                self.informationLabel.text = "Oops! A fatal error occurs ..."
            })
        }
    }
    
    /**
     Add coordinates into the Coordinate object
     
     - Parameter neighbourhood: The parent neighbourhood that the coordinate belongs to
     - Parameter coordinates: The coordinate array need to save in
     */
    func addCoordinatesForNeighbourhood(neighbourhood: Neighbourhood, coordinates: NSArray){
        
        for xyz in coordinates{
            let coordinate = NSEntityDescription.insertNewObjectForEntityForName("Coordinate", inManagedObjectContext: self.privateContext) as! Coordinate
            let point = xyz as! NSArray
            coordinate.longitude = NSNumber(double: point[0] as! Double)
            coordinate.latitude = NSNumber(double: point[1] as! Double)
            coordinate.neighbourhood = neighbourhood
        }
    }
    
    // MARK: - Preload Application Data
    func preloadApplictionsIfNeeded(){
        dispatch_async(dispatch_get_main_queue(), {
            self.fetchDevAppsFromServer()
        })
    }
    
    /**
     Use Alamofire for the data fetching
     */
    
    func fetchDevAppsFromServer(){
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"		]
        
        informationLabel.text = "Looking up for most interesting urban activities ..."
        Alamofire.request(.GET, NSURL(string: "\(Connection.MilieuServerBaseUrl)\(RequestType.FetchAllApplications.rawValue)")!, headers: headers).responseJSON{
            response in
            
            debugPrint(response.result.error)
            if let _ = response.result.error{
                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.text = "Oops! Can not find the insteresting activities, \nrelaunch the app pls ..."
                })
                AR5Logger.debug("\(response.result.error?.userInfo)")
                return
            }
            
            debugPrint(response.response)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let result = response.result.value{
                    AR5Logger.debug("\(result)")
                    self.handleDevAppResults(result)
                }
            })
            
            
        }
    }
    
    func handleDevAppResults(result: AnyObject){
        
        if let siteApps = result as? NSArray{
            privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.persistentStoreCoordinator = coreDataStack.context.persistentStoreCoordinator
            privateContext.performBlock{
                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.text = "Finalize the treasure map ..."
                    self.percentLabel.hidden = false
                    self.percentLabel.text = "0 %"
                })
                var count = 0
                var percent = 0
                let appsCount = siteApps.count
                AR5Logger.debug("Total Apps: \(appsCount)")
                for app in siteApps{
                    if let app = app as? NSDictionary{
                        if let wardNum: Int = app["ward_num"] as? Int {
                            AR5Logger.debug("App Info: \(app)")
                            let appObject = NSEntityDescription.insertNewObjectForEntityForName("DevApp", inManagedObjectContext: self.privateContext) as! DevApp
                            appObject.applicationId = app["id"] as? String
                            appObject.applicationType = app["application_type"] as? String
                            appObject.developmentId = app["devID"] as? String
                            appObject.id = NSNumber(integer: (app["id"] as? Int)!)
                            appObject.generalDesription = app["description"] as? String
                            appObject.imageUrl = app["image_url"] as? String
                            appObject.address = app["address"] as? String
                            if let lon = app["longitude"] as? Double{
                                let number = NSNumber(double: lon)
                                AR5Logger.debug("\(NSNumber(double: lon))")
                                appObject.longitude = NSNumber(double: lon)
                            }
                            if let lat = app["latitude"] as? Double{
                                AR5Logger.debug("\(NSNumber(double: lat))")
                                appObject.latitude = NSNumber(double: lat)
                            }

                            self.addAddressesForDevApp(appObject, addresses: app["addresses"] as! NSArray)
                            self.addStatusesForDevApp(appObject, statuses: app["statuses"] as! NSArray)
                            self.addDevAppInNeighbourhood(appObject, withWardNum: wardNum)
                        }
                    }
                    count += 1
                    if count % (Int(appsCount/10)) == 0{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.percentLabel.text = "\(percent) %"
                        })
                        if percent < 100{
                            percent += 10
                        }
                    }
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.informationLabel.hidden = false
                    self.percentLabel.hidden = false
                })
                
                self.finishPreload()
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
            if let street = address["street"] as? String{
                let addressObject = NSEntityDescription.insertNewObjectForEntityForName("Address", inManagedObjectContext: self.privateContext) as! Address
                addressObject.id = NSNumber(integer: (address["id"] as? Int)!)
                addressObject.street = street
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
            let statusObject = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: self.privateContext) as! Status
            statusObject.id = NSNumber(integer: (status["id"] as? Int)!)
            statusObject.status = status["status"] as? String
            statusObject.statusDate = DateUtil.transformDateFromString(status["status_date"] as? String, withFormat: .UTCStandardFormat)
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
            let results = try self.privateContext.executeFetchRequest(fetchRequest) as! [Neighbourhood]
            
            // If there is no data, load json file in
            if results.count > 0{
                let neighbourhood = results.first!
                let devApps = neighbourhood.devApps!.mutableCopy() as! NSMutableSet
                devApps.addObject(appObject)
                neighbourhood.devApps = devApps.copy() as? NSSet
            }
            
            try self.privateContext.save()
            self.privateContext.reset()
            
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
            dispatch_async(dispatch_get_main_queue(), {
                self.informationLabel.text = "Oops! Map is teared by the kitten"
            })
        }
    }
}

