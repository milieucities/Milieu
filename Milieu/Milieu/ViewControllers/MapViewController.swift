//
//  FirstViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 15/12/6.
//  Copyright © 2015年 Atelier Ruderal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - UI Labels
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
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
    
    // MARK: - VC methods
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showLocationSelectionView()
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
            
            coordinatesLabel.text = "\(latitudeText), \(longitudeText)"
            
            if let placemark = placemark{
                locationLabel.text = stringFromPlacemark(placemark)
            }else if performingReverseGeocoding{
                locationLabel.text = "Searching..."
            }else{
                locationLabel.text = "No Address Found"
            }
        }else{
            coordinatesLabel.text = ""
            locationLabel.text = ""
        }
    }
    
    func showUser(){
        let coordinate = mapView.userLocation.coordinate
        AR5Logger.debug("!!!Coordinate:\(coordinate)")
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
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
            
//            // Create the blur effect view
//            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            let blurEffectView = UIVisualEffectView(effect: blurEffect)
//            blurEffectView.frame = self.view.bounds
//            
//            // Add the blur effect into the viewcontroller
//            locationSelectionVC.view.frame = self.view.bounds
//            locationSelectionVC.view.backgroundColor = UIColor.clearColor()
//            locationSelectionVC.view.insertSubview(blurEffectView, atIndex: 0)
//            locationSelectionVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            
            // TODO: Add vibrancy effect
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
                self.showUser()
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

