//
//  LocationSelectionViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2015-12-12.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

protocol LocationSelectionDelegate: class{
    func selectNeighbourhood(neighbourhood: Neighbourhood, withRegion region: MKCoordinateRegion?)
}

class LocationSelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var backgroundColoredViews: [UIView]!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var selectedLoctionBtn: UIButton!
    
    var coreDataStack: CoreDataStack!
    weak var delegate: LocationSelectionDelegate?
    
    var neighbourhoods: [Neighbourhood]!
    var selectedNeighbourhood: Neighbourhood?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // Clear background colors from labels and buttons
        for view in backgroundColoredViews{
            view.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        neighbourhoods = fetchNeighbourhoods()
    }
    
    @IBAction func showLocation(sender: AnyObject) {
        if let neighbour = selectedNeighbourhood{
            self.delegate?.selectNeighbourhood(neighbour, withRegion: regionForSelectedNeighbourhood(neighbour.name!))
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            selectedLoctionBtn.setTitle("Please choose a location", forState: .Normal)
        }
        
    }
    
    @IBAction func useCurrentLocation(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("Ottawa", forKey: DefaultsKey.Location)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
    
    // Mark: - Get Ward Data
    func fetchNeighbourhoods() -> [Neighbourhood]{
        let fetchRequest = NSFetchRequest(entityName: "Neighbourhood")
        let predicate = NSPredicate(format: "city.name == %@", "OTTAWA")
        fetchRequest.predicate = predicate
        
        do{
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Neighbourhood]
            
            return results
            
        }catch let error as NSError{
            print("ERROR: \(error.localizedDescription)")
            return [Neighbourhood]()
        }
    }
    
    // MARK: - Populate Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return neighbourhoods.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return neighbourhoods[row].name
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = neighbourhoods[row].name!
        let myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name:"PingFang TC", size: 18.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNeighbourhood = neighbourhoods[row]
        selectedLoctionBtn.setTitle("\(selectedNeighbourhood!.name!), OTTAWA", forState: .Normal)
    }
}

