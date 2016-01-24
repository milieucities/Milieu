	//
//  FirstViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015 Atelier Ruderal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import STPopup
import CoreData

class MapViewController: UIViewController {

    // MARK: - UI Labels
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var locationMenuButton: UIBarButtonItem!
    
    
    // MARK: - VC properties
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: NSTimer?
    let regionRedius : CLLocationDistance = 1000
    var createFakeLocation: Bool = true
    var loadInitialLocation: Bool = true
    var coreDataStack: CoreDataStack!
    var shouldUpdateMap: Bool = true
    var events: [EventInfo]!
    
    // MARK: - VC methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        coreDataStack = CoreDataManager.sharedManager.coreDataStack
        
        if revealViewController() != nil{
            revealViewController().rearViewRevealWidth = 260
            locationMenuButton.target = revealViewController()
            locationMenuButton.action = "revealToggle:"
            
            revealViewController().rightViewRevealWidth = 220
            menuButton.target = revealViewController()
            menuButton.action = "rightRevealToggle:"
        }
        events = EventInfo.loadAllEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let neighbourManager = NeighbourManager.sharedManager
        if let neighbourhood = neighbourManager.currentNeighbour, let region = neighbourManager.currentRegion{
            populateMapSectionWithNeighbour(neighbourhood, withRegion: 	region)
            neighbourManager.reset()
        }else{
            if !shouldUpdateMap{
                return
            }
            
            // Load the defaults value
            let defaults = NSUserDefaults.standardUserDefaults()
            let defaultLocation: String? = defaults.objectForKey(DefaultsKey.SelectedNeighbour) as? String
            if defaultLocation == nil || defaultLocation!.isEmpty{
                showLocationSelectionView()
            }else if defaultLocation != DefaultsValue.UserCurrentLocation{
                let neighbourManager = NeighbourManager.sharedManager
                neighbourManager.setCurrentNeighbourWithName(defaultLocation!)
                populateMapSectionWithNeighbour(neighbourManager.currentNeighbour!, withRegion: neighbourManager.currentRegion)
                neighbourManager.reset()
            }else{
                getLocation()
                shouldUpdateMap = false
            }
        }
    }

    // MARK: - Map Display
    /**
     Update the coordinate and location labels
    */
    func updateLabels(){
        if let location = location{
            let latitudeText = String(format: "%.8f", location.coordinate.latitude)
            let longitudeText = String(format: "%.8f", location.coordinate.longitude)
            
            AR5Logger.debug("\(latitudeText), \(longitudeText)")
            
        }
    }
    
    /**
     Show the user's current location
    */
    func showUser(){
        
        // Get the user current location
        let coordinate = mapView.userLocation.coordinate
        
        AR5Logger.debug("!!!Coordinate:\(coordinate)")
        
        // Transfer the user current location from CLLocationCoordinate2D to CLLocation for centering map
        let userLocation: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        centerMapOnLocation(userLocation ?? CLLocation(latitude: 45.423, longitude: -75.702))
    }
    
    /**
     Center the map to the given location region
    */
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2.0, regionRedius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    /**
     Populate the annotations on the map according to the neighbourhood and the region
    */
    func populateMapSectionWithNeighbour(neighbourhood: Neighbourhood, withRegion region: MKCoordinateRegion?){
        if let region = region{
            
            var applicationInfos = [MilieuAnnotation]()
 
            let predicate1 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2016-01'")
            let predicate2 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2015-12'")
            let predicate3 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2015-11'")
            let predicate4 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2015-10'")
            let predicate5 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2015-09'")
            let predicate6 = NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '2015-08'")
            
            let predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [predicate1, predicate2, predicate3, predicate4, predicate5, predicate6])
            let filteredDevApps = (neighbourhood.devApps! as NSSet).filteredSetUsingPredicate(predicate)
            
            for item in filteredDevApps{
                let app = item as! DevApp
                if let _ = app.addresses?.allObjects.first as? Address{
                    let appInfo = ApplicationInfo(devApp: app)
                    applicationInfos.append(appInfo)
                }
            }
            
            for event in events{
                if event.wardName == neighbourhood.name{
                    applicationInfos.append(event)
                }
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(neighbourhood.name, forKey: DefaultsKey.SelectedNeighbour)
            defaults.synchronize()
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.showsUserLocation = true
            mapView.setRegion(region, animated: false)
            mapView.addAnnotations(applicationInfos)
            shouldUpdateMap = false
        }
    }
    
    func getCurrentDate() -> (year: Int, month: Int){
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar
        let components = calendar().components([.Day, .Month, .Year], fromDate: currentDate)
        return(components.year, components.month)
    }
    
    // TODO: Improve to support general case
    func createRecentPredicate(months: Int) -> [NSPredicate]{
        let currentYear = getCurrentDate().year
        let currentMonth = getCurrentDate().month
        
        var predicates = [NSPredicate]()
        var m: Int
        for m = 0; m < months; ++m{
            
            let predicate: NSPredicate
            if currentMonth - m > 0{
                
                if currentMonth - m < 10{
                    predicate =  NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '%d-0%d'", currentYear, currentMonth - m)
                    let string = String(format: "statuses[FIRST].statusDate BEGINSWITH '%d-0%d'", currentYear, currentMonth - m)
                    print("\(string)")
                }else{
                    predicate =  NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '%d-%d'", currentYear, currentMonth - m)
                    print("\(String(format: "statuses[FIRST].statusDate BEGINSWITH '%d-%d'", currentYear, currentMonth - m))")
                }
                
            }else{
                
                if currentMonth + 12 - m < 10{
                    predicate =  NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '%d-0%d'", currentYear - 1, currentMonth + 12 - m)
                    print("\(String(format: "statuses[FIRST].statusDate BEGINSWITH '%d-0%d'", currentYear - 1, currentMonth + 12 - m))")
                }else{
                    predicate =  NSPredicate(format: "statuses[FIRST].statusDate BEGINSWITH '%d-%d'", currentYear - 1, currentMonth + 12 - m)
                    print("\(String(format: "statuses[FIRST].statusDate BEGINSWITH '%d-%d'", currentYear - 1, currentMonth + 12 - m))")
                }
            }
            predicates.append(predicate)
        }
        
        return predicates
    }
    
    // MARK: - Blur Effect
    func showLocationSelectionView(){
        self.performSegueWithIdentifier("mapToLocationSelection", sender: self)
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapToLocationSelection"{
            let locationSelectionVC = segue.destinationViewController as! LocationSelectionViewController

            // Show the location selection view on top of the current map view
            locationSelectionVC.view.frame = self.view.bounds
            locationSelectionVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            locationSelectionVC.hidesBottomBarWhenPushed = true
            locationSelectionVC.coreDataStack = coreDataStack
            locationSelectionVC.delegate = self
        }
    }
    
    // MARK: - Buttons
    
    @IBAction func recenterUserLocation(sender: AnyObject) {
        showUser()
    }
    
}

    // MARK: - MapViewDelegate Extension
extension MapViewController: MKMapViewDelegate{
    
    /**
     Add animation when the annotation is added
    */
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        var i = -1
        
        for view in views{
            i++
            
            if view.annotation is MKUserLocation{
                continue
            }
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
            
            // Animate drop
            let delay = 0.03 * Double(i)
            UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        view.transform = CGAffineTransformMakeScale(1.0, 0.8)
                        
                        }, completion: {(Bool) in
                            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                view.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
                    
            })
        }
    }
    
    /**
     Create and customize the annotation view
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MilieuAnnotation{
            // Make unique reusable identifier for these type annotation
            let identifier = annotation.category.rawValue
            var view: MKAnnotationView
            
            // dequeue annotation and reusable annotation based on identifier
            if let dequeuedView: MKAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier){
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                // No reusable annotation found, Create a new one
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let image = UIImage(named: annotation.category.rawValue)
                view.image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                // TODO: Make it be able to use tint color
                view.tintColor = UIColor(red: 158.0/255.0, green: 211.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Deselect the annotation so that it can be chosen again after dismissing the detail view controller
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        if let annotation = view.annotation as? ApplicationInfo{
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ApplicationDetailViewController") as? ApplicationDetailViewController
            
            // Set the annotation
            viewController?.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.cornerRadius = 4
            
            // Show it on top of the map view
            popupController.presentInViewController(self)
            
        }else if let annotation = view.annotation as? EventInfo{
            // Create the ApplicationDetailViewController by storyboard
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as? EventDetailViewController
            
            // Set the annotation
            viewController?.annotation = annotation
            
            // Use the STPopupController to make the fancy view controller
            let popupController = STPopupController(rootViewController: viewController)
            popupController.cornerRadius = 4
            
            // Show it on top of the map view
            popupController.presentInViewController(self)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate{
    // MARK: - Location Logic
    /**
    Trigger the location update
    */
    func getLocation(){
        
        // Check whether location services is enable or not
        let authSatuts = CLLocationManager.authorizationStatus()
        
        // If location services is not determined, ask user to authorize to use
        if authSatuts == .NotDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // If location services is denied or restricted, pop up alert
        if authSatuts == .Denied || authSatuts == .Restricted{
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            // Config the manager and begin to udpate
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
        
    }
    
    func stopLocationManager(){
        if updatingLocation{
            if let timer = timer{
                timer.invalidate()
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func didTimeOut(){
        print("*** Time out")
        
        if location == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
        }
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String{
        
        // Prepare a location string
        var area = ""
        
        if let s = placemark.thoroughfare{
            area += s + ", "
        }
        if let s = placemark.locality{
            area += s
        }
        
        return area
    }
    
    // MARK: - Location Manager Delegate Methods
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        AR5Logger.debug("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue{
            return
        }else if error.code == CLError.Denied.rawValue{
            showLocationServicesDeniedAlert()
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        AR5Logger.debug("didUpdateLocations \(newLocation)")
        
        // Check location accuracy, if reach certain level, stop the manager
        if newLocation.timestamp.timeIntervalSinceNow < -5{
            return
        }
        
        if newLocation.horizontalAccuracy < 0{
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location{
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            lastLocationError = nil
            location = newLocation
            updateLabels()
        }
        
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
            AR5Logger.debug("*** We're done!")
            stopLocationManager()
            
            if distance > 0{
                performingReverseGeocoding = false
            }
        }
        
        if !performingReverseGeocoding{
            AR5Logger.debug("*** Going to geocode")
            
            performingReverseGeocoding = true
            
            geocoder.reverseGeocodeLocation(newLocation){
                placemarks, error in
                
                print("*** Found placemarks: \(placemarks), error: \(error)")
                
                // Update the geo location after reverse it
                self.lastGeocodingError = error
                if error == nil, let p = placemarks where !p.isEmpty{
                    self.placemark = p.last!
                }else{
                    self.placemark = nil
                }
                
                self.performingReverseGeocoding = false
                self.updateLabels()
                
                // Load the user current initial location once
                if self.loadInitialLocation{
                    self.centerMapOnLocation(self.location ?? CLLocation(latitude: 45.423, longitude: -75.702))
                    self.loadInitialLocation = false
                }

            }
        }else if distance < 1.0{
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10{
                AR5Logger.debug("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    // MARK: - Alert
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Seetings.", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let setAction = UIAlertAction(title: "Settings", style: .Default){
            action in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            
        }
        
        alert.addAction(okAction)
        alert.addAction(setAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

}
    
    extension MapViewController: LocationSelectionDelegate{
        func selectNeighbourhood(neighbourhood: Neighbourhood, withRegion region: MKCoordinateRegion?) {
            populateMapSectionWithNeighbour(neighbourhood, withRegion: region)
        }
    }

