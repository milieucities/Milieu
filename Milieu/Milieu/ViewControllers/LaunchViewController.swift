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
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    var coreDataStack: CoreDataStack!
    var neighbourhoods: [Neighbourhood]?
    var privateContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        indicator.isHidden = false
        indicator.startAnimating()
        self.navigationController?.navigationBar.isTranslucent = true
        informationLabel.text = "Getting the map from the bookshelf ..."
        privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = coreDataStack.context.persistentStoreCoordinator
        privateContext.perform{
            self.preloadData()
        }
    }
    
    /**
     Preload all required data either from the data base or server connection
     */
    func preloadData(){
        // Find or Create Neighbourhood Data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Neighbourhood")
        fetchRequest.resultType = .countResultType
        
        do{
            // Check the neighbourhood objects count
            let results = try self.privateContext.fetch(fetchRequest)
            
            // If there is no data, load json file in
            if results.count == 0{
                insertWardsDataFromApi()
            }else{
                finishPreload()
            }
        }catch let error as NSError{
            AR5Logger.debug("Can't fetch data: \(error.localizedDescription)")
            DispatchQueue.main.async(execute: {
                self.informationLabel.text = "Oops! A fatal error occurs ..."
            })
        }
    }
    
    /**
     Finish the preloading process, stop the indicator and segue to the next view controller
     */
    func finishPreload(){
        DispatchQueue.main.async(execute: {
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.performSegue(withIdentifier: "landingToTabBar", sender: self)
        })
    }
    
    // MARK: - Preload Neighbourhood Data

    func insertWardsDataFromApi(){
        
        // TODO: change to fetch wards page by page.
        Alamofire.request(URL(string: "\(Connection.OpenNorthBaseUrl)\(OpenNorthApi.FindOttawaWards.rawValue)")!, method: .get).responseJSON{
            response in
            
            if let _ = response.result.error{
                DispatchQueue.main.async(execute: {
                    self.informationLabel.text = "Oops! Can not find the secret path, \nrelaunch the app pls ..."
                })
                AR5Logger.debug("\(response.result.error.debugDescription)")
                return
            }
            
            if let result = response.result.value{
                self.privateContext.perform{
                    self.parseWardsFromDict(result as! [String: AnyObject])
                }
                
            }

        }
    }
    
    func parseWardsFromDict(_ dict: [String: AnyObject]){
        let wards = dict["objects"] as! [[String: AnyObject]]
        // TODO: If the coredata city wards count is less than Api returned wards count, update the coredata
        
        // Create city in the CoreData
        let cityEntity = NSEntityDescription.entity(forEntityName: "City", in: self.privateContext)!
        let city = City(entity: cityEntity, insertInto:  privateContext)
        city.name = "OTTAWA"
        
        // Create entity description
        let entity = NSEntityDescription.entity(forEntityName: "Neighbourhood", in: self.privateContext)!
        
        DispatchQueue.main.async(execute: {
            self.informationLabel.text = "Desgining the blueprint ..."
            self.percentLabel.isHidden = false
            self.percentLabel.text = "0 %"
        })
        
        for ward in wards{
            let wardNumber = Int(ward["external_id"] as! String)!
            let wardName = ward["name"] as! String
            
            // Create entity
            let neighbourhood = Neighbourhood(entity: entity, insertInto: self.privateContext)
            neighbourhood.name = wardName
            neighbourhood.number = NSNumber(value: wardNumber as Int)
            neighbourhood.city = city
        }
        
        do{
            try self.privateContext.save()
            self.privateContext.reset()
            insertWardBoundsFromApi()
        }catch let error as NSError{
            AR5Logger.debug("Error: \(error.localizedDescription)")
            DispatchQueue.main.async(execute: {
                self.informationLabel.text = "Oops! A fatal error occurs ..."
            })
        }
    }
    
    func insertWardBoundsFromApi(){
        // TODO: change to fetch wards page by page.
        
        Alamofire.request(URL(string: "\(Connection.OpenNorthBaseUrl)\(OpenNorthApi.FindOttawaWardsSimpleShape.rawValue)")!, method: .get).responseJSON{
            response in
            
            if let _ = response.result.error{
                DispatchQueue.main.async(execute: {
                    self.informationLabel.text = "Oops! Can not find the secret path, \nrelaunch the app pls ..."
                })
                AR5Logger.debug("\(response.result.error.debugDescription)")
                return
            }
            
            if let result = response.result.value{
                self.privateContext.perform{
                    self.parseBoundariesFromDict(result as! [String: AnyObject])
                }
            }
        }
    }
    
    func parseBoundariesFromDict(_ dict: [String: AnyObject]){
        let boundaries = dict["objects"] as! [[String: AnyObject]]
        
        var count = 0
        for boundary in boundaries{
            
            let simpleShape = boundary["simple_shape"] as! [String: AnyObject]
            let coordinates = ((simpleShape["coordinates"] as! NSArray)[0] as! NSArray)[0] as! NSArray
            
            // Find or Create Neighbourhood Data
            let fetchRequest: NSFetchRequest<Neighbourhood> = NSFetchRequest(entityName: "Neighbourhood")
            let predicate = NSPredicate(format: "name == %@", (boundary["name"] as! String))
            fetchRequest.predicate = predicate
            
            do{
                // Check the neighbourhood objects count
                let results = try self.privateContext.fetch(fetchRequest)
                
                // If there is no data, load json file in
                if results.count > 0{
                    let neighbourhood = results.first!
                    
                    addCoordinatesForNeighbourhood(neighbourhood, coordinates: coordinates)
                }
                
                try self.privateContext.save()
                self.privateContext.reset()
                
                count += 1
                DispatchQueue.main.async(execute: {
                    self.percentLabel.text = "\(Int (count * 100 / boundaries.count)) %"
                })
                
            }catch let error as NSError{
                AR5Logger.debug("Error: \(error.localizedDescription)")
                DispatchQueue.main.async(execute: {
                    self.informationLabel.text = "Oops! A fatal error occurs ..."
                })
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.percentLabel.isHidden = true
            self.informationLabel.isHidden = false
            self.percentLabel.isHidden = false
        })
        
        self.finishPreload()
    }
    
    /**
     Add coordinates into the Coordinate object
     
     - Parameter neighbourhood: The parent neighbourhood that the coordinate belongs to
     - Parameter coordinates: The coordinate array need to save in
     */
    func addCoordinatesForNeighbourhood(_ neighbourhood: Neighbourhood, coordinates: NSArray){
        
        for xyz in coordinates{
            let coordinate = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: self.privateContext) as! Coordinate
            let point = xyz as! NSArray
            coordinate.longitude = NSNumber(value: point[0] as! Double as Double)
            coordinate.latitude = NSNumber(value: point[1] as! Double as Double)
            coordinate.neighbourhood = neighbourhood
        }
    }
}

