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

class MapViewController: UIViewController {

    // MARK: - UI Labels
    @IBOutlet weak var mapView: MKMapView!
    
    
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
    
    // MARK: - VC methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        showUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the defaults value
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultLocation: String? = defaults.objectForKey(DefaultsKey.Location) as? String
        if defaultLocation == nil || defaultLocation!.isEmpty{
            showLocationSelectionView()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

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
     Show a fake location that always has a certain distance with the current user location
    */
    func showFakeApplication(){
        if createFakeLocation{
            let coordinateA = CLLocationCoordinate2DMake((location?.coordinate.latitude ?? 45.423) + 0.003, (location?.coordinate.longitude ?? -75.702) + 0.002)
            let coordinateB = CLLocationCoordinate2DMake((location?.coordinate.latitude ?? 45.423) - 0.002, (location?.coordinate.longitude ?? -75.702) - 0.004)
            let coordinateC = CLLocationCoordinate2DMake((location?.coordinate.latitude ?? 45.423) + 0.005, (location?.coordinate.longitude ?? -75.702) - 0.006)
            
            let imageA: UIImage = UIImage(named: "office_building_example.png")!
            let imageB: UIImage = UIImage(named: "construction_example.png")!
            let imageC: UIImage = UIImage(named: "demolition_example.png")!
            
            let applicationA = ApplicationInfo(title: "Hello, office", type: ApplicationType.OfficeBuilding, coordinate: coordinateA, image: imageA)
            let applicationB = ApplicationInfo(title: "Don't touch", type: ApplicationType.Construction, coordinate: coordinateB, image: imageB)
            let applicationC = ApplicationInfo(title: "Say bye-bye", type: ApplicationType.Demolition, coordinate: coordinateC, image: imageC)
            mapView.addAnnotation(applicationA)
            mapView.addAnnotation(applicationB)
            mapView.addAnnotation(applicationC)
            
            createFakeLocation = false
        }
    }
    
    /**
     Center the map to the given location region
    */
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2.0, regionRedius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
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
        }
    }
    
    // MARK: - Buttons
    
    @IBAction func recenterUserLocation(sender: AnyObject) {
        showUser()
        showFakeApplication()
    }
    
}

extension MapViewController: MKMapViewDelegate{
    
    /**
     Create and customize the annotation view
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ApplicationInfo{
            // Make unique reusable identifier for these type annotation
            let identifier = annotation.type.rawValue
            var view: MKAnnotationView
            
            // dequeue annotation and reusable annotation based on identifier
            if let dequeuedView: MKAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier){
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                // No reusable annotation found, Create a new one
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named: annotation.type.rawValue)
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

